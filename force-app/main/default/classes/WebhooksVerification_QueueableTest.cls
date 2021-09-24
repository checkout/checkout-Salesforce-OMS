@isTest
private class WebhooksVerification_QueueableTest {
  @isTest
  private static void postFirstWebhookTest() {
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();
    config.Secret_Key__c = '12345';
    config.Webhook_Endpoint__c = 'https://www.OSF.com/notification';

    Test.setMock(HttpCalloutMock.class, new NoWebhookConfiguredMock());
    Test.startTest();

    ID jobID = System.enqueueJob(
      new WebhooksVerification_Queueable(
        new List<Checkout_Payment_Config__c>{ config }
      )
    );

    Test.stopTest();

    system.assertEquals(
      'Completed',
      [SELECT Status FROM AsyncApexJob WHERE Id = :jobID]
      .Status,
      'Job failed'
    );
  }

  @isTest
  private static void postNewWebhookTest() {
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();
    config.Secret_Key__c = '12345';
    config.Webhook_Endpoint__c = 'https://www.OSF.com/notification';

    Test.setMock(HttpCalloutMock.class, new WebhookConfiguredMock());

    Test.startTest();

    ID jobID = System.enqueueJob(
      new WebhooksVerification_Queueable(
        new List<Checkout_Payment_Config__c>{ config }
      )
    );

    Test.stopTest();

    system.assertEquals(
      'Completed',
      [SELECT Status FROM AsyncApexJob WHERE Id = :jobID]
      .Status,
      'Job failed'
    );
  }

  @isTest
  private static void postExceptionTest() {
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();
    config.Secret_Key__c = '12345';
    config.Webhook_Endpoint__c = 'https://www.OSF.com/notification';
    Test.setMock(HttpCalloutMock.class, new InvalidRequestMock());
    Test.startTest();
    System.enqueueJob(
      new WebhooksVerification_Queueable(
        new List<Checkout_Payment_Config__c>{ config }
      )
    );

    Test.stopTest();

    List<Exception_Log__c> exceptions = [
      SELECT Exception_Message__c
      FROM Exception_Log__c
    ];

    System.assertEquals(1, exceptions.size(), 'should have 1 exception');

    System.assert(
      exceptions[0].Exception_Message__c.Contains('StatusCode: 400'),
      'Wrong exeption was throw'
    );
  }

  private class NoWebhookConfiguredMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      request.setEndpoint('callout:Checkout_Payment/webhooks');
      request.setHeader(Constants.CONTENT_TYPE, Constants.JSON);
      response.setStatusCode(200);
      response.setBody('[]');
      return response;
    }
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

  private class InvalidRequestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      request.setEndpoint('callout:Checkout_Payment/webhooks');
      request.setHeader(Constants.CONTENT_TYPE, Constants.JSON);
      response.setStatusCode(400);
      return response;
    }
  }
}
