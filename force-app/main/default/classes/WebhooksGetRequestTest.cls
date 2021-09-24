@isTest
private class WebhooksGetRequestTest {
  @isTest
  private static void createGetRequestTest() {
    WebhooksGetRequest service = new WebhooksGetRequest('1234');

    HttpRequest request = service.getRequest();

    System.assertNotEquals(null, request, 'Request not created');
    System.assertEquals(
      'callout:Checkout_Payment/webhooks',
      request.getEndpoint(),
      Constants.INVALID_ENDPOINT
    );
    System.assertEquals(
      '1234',
      request.getHeader(Constants.AUTHORIZATION),
      Constants.INVALID_AUTHORIZATION_HEADER
    );
    System.assertEquals(
      Constants.HTTP_METHOD_GET,
      request.getMethod(),
      Constants.INVALID_HTTP_METHOD
    );
  }
}
