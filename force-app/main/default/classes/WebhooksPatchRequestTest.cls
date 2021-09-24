@isTest
private class WebhooksPatchRequestTest {
  @isTest
  private static void createPatchRequestTest() {
    String secretKey = 'sk_test_789abc12-aaa1-bbb2-ccc3-aaa444bbb456';
    List<String> eventTypes = new List<String>{
      'Payment_refund_declined',
      'Payment_refunded'
    };
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();

    config.Secret_Key__c = secretKey;
    config.Webhook_Endpoint__c = 'test.com/notification';

    WebhooksWrapper webhook = new WebhooksWrapper();

    webhook.active = true;
    webhook.content_type = Constants.JSON;
    webhook.id = 'wb_45';
    webhook.url = 'test.com/notification';
    webhook.event_types = eventTypes;

    WebhooksPatchRequest service = new WebhooksPatchRequest(webhook, config);
    HttpRequest request = service.getRequest();

    System.assertNotEquals(null, request, 'Request not created');
    System.assertEquals(
      'callout:Checkout_Payment/webhooks/wb_45',
      request.getEndpoint(),
      Constants.INVALID_ENDPOINT
    );
    System.assertEquals(
      secretKey,
      request.getHeader(Constants.AUTHORIZATION),
      Constants.INVALID_AUTHORIZATION_HEADER
    );
    System.assertEquals(
      Constants.HTTP_METHOD_PATCH,
      request.getMethod(),
      Constants.INVALID_HTTP_METHOD
    );
    System.assertEquals(returnBody(), request.getBody(), 'Invalid body');
  }

  private static string returnBody() {
    Map<String, Object> respBody = new Map<String, Object>{
      'active' => true,
      'content_type' => Constants.JSON,
      'event_types' => new List<String>{
        'Payment_refund_declined',
        'Payment_refunded'
      },
      'id' => 'wb_45',
      'url' => 'test.com/notification'
      
    };

    return JSON.serialize(respBody);
  }
}
