@isTest
private class WebhooksPostRequestTest {
  @isTest
  private static void createPostRequestTest() {
    String secretKey = 'sk_test_789abc12-aaa1-bbb2-ccc3-aaa444bbb456';
    List<String> eventTypes = new List<String>{
      'Payment_refund_declined',
      'Payment_refunded'
    };
    Checkout_Payment_Config__c config = new Checkout_Payment_Config__c();

    config.Secret_Key__c = secretKey;
    config.Webhook_Endpoint__c = 'test.com/notification';

    WebhooksPostRequest service = new WebhooksPostRequest(eventTypes, config);
    HttpRequest request = service.getRequest();

    System.assertNotEquals(null, request, 'Request not created');
    System.assertEquals(
      'callout:Checkout_Payment/webhooks',
      request.getEndpoint(),
      Constants.INVALID_ENDPOINT
    );
    System.assertEquals(
      secretKey,
      request.getHeader(Constants.AUTHORIZATION),
      Constants.INVALID_AUTHORIZATION_HEADER
    );
    System.assertEquals(
      Constants.HTTP_METHOD_POST,
      request.getMethod(),
      Constants.INVALID_HTTP_METHOD
    );
    System.assertEquals(
      returnBody().length(),
      request.getBody().length(),
      'Invalid body'
    );
  }

  private static string returnBody() {
    Map<String, Object> respBody = new Map<String, Object>{
      'active' => true,
      'id' => null,
      'content_type' => Constants.JSON,
      'event_types' => new List<String>{
        'Payment_refund_declined',
        'Payment_refunded'
      },
      'url' => 'test.com/notification'
    };

    return JSON.serialize(respBody);
  }
}
