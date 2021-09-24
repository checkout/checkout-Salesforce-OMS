@istest
private class CheckoutPaymentConfigTriggerTest {
  @istest
  private static void testBeforeInsert() {
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();

    config.Secret_Key__c = 'secretKey';
    config.Webhook_Endpoint__c = 'test.com/notification';

    Test.setMock(HttpCalloutMock.class, new WebhookConfiguredMock());

    Test.startTest();
    insert config;
    Test.stopTest();

    System.assertEquals(
      1,
      [SELECT COUNT() FROM AsyncApexJob WHERE Status = 'Completed'],
      'Insert failed'
    );
  }

  @isTest
  private static void validateCurrentConfigsTest() {
    Exception exTest;

    List<Checkout_Payment_Config__c> configs = new List<Checkout_Payment_Config__c>();

    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();
    config.Active__c = false;
    config.Name = 'Test1';

    Checkout_Payment_Config__c config2 = new Checkout_Payment_Config__c();
    config2.Active__c = false;
    config2.Name = 'Test2';

    configs.add(config);
    configs.add(config2);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new WebhookConfiguredMock());
    insert configs;
    List<Checkout_Payment_Config__c> updateList = new List<Checkout_Payment_Config__c>();
    config.Active__c = true;
    config2.Active__c = true;

    updateList.add(config);
    updateList.add(config2);
    try {
      Database.update(updateList);
    } catch (Exception ex) {
      exTest = ex;
    }
    Test.stopTest();

    System.assert(exTest != null, 'An error should be catched.');
    System.assert(
      exTest.getMessage().contains(Constants.CONFIG_ALREADY_ACTIVE),
      'The error messages should contain: There is another payment configuration already active, please disable it before activating a new one.'
    );
  }

  @isTest
  private static void testBeforeUpdate() {
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();

    config.Secret_Key__c = 'secretKey';
    config.Webhook_Endpoint__c = 'test.com/notification';

    Test.setMock(HttpCalloutMock.class, new WebhookConfiguredMock());

    Test.startTest();
    insert config;

    config.Active__C = true;

    update config;
    Test.stopTest();

    System.assertEquals(
      0,
      [SELECT COUNT() FROM AsyncApexJob WHERE Status != 'Completed'],
      'update failed'
    );
  }

  private class WebhookConfiguredMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();
      WebhooksWrapper webhooks = new WebhooksWrapper();

      webhooks.active = true;
      webhooks.content_type = Constants.JSON;
      webhooks.event_types = new List<String>{ 'payment_captured' };
      webhooks.url = 'https://www.OSF.com/notification';

      request.setEndpoint('callout:Checkout_Payment/webhooks');
      request.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      response.setStatusCode(200);
      response.setBody(JSON.serialize(new List<WebhooksWrapper>{ webhooks }));

      return response;
    }
  }
}
