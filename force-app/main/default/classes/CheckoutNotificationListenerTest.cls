@isTest
private class CheckoutNotificationListenerTest {
  private static final String DEFAULT_NOTIFICATIONS_URL = '/services/apexrest/app/Checkout_Notifications';

  private static String returnBody() {
    Map<String, Object> respBody = new Map<String, Object>{
      'data' => new Map<String, Object>{ 'id' => 'pay_4567' },
      'type' => Enums.WebhookRequestType.PAYMENT_CAPTURED
    };

    return JSON.serialize(respBody);
  }

  @isTest
  private static void testStatus200() {
    RestRequest req = new RestRequest();
    req.requestURI = DEFAULT_NOTIFICATIONS_URL;
    req.httpMethod = Constants.HTTP_METHOD_POST;
    req.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

    String body = returnBody();
    req.addHeader(Constants.CKO_SIGNATURE, getSignature(body));

    req.requestBody = Blob.valueOf(body);

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.setMock(HttpCalloutMock.class, new PostNotificationMock());

    Test.startTest();
    CheckoutNotificationListener.handlePost();
    Test.stopTest();

    System.assertEquals(
      200,
      RestContext.response.statusCode,
      Constants.WRONG_STATUS_CODE
    );
  }

  @isTest
  private static void testStatusNullAdapter() {
    RestRequest req = new RestRequest();
    req.requestURI = DEFAULT_NOTIFICATIONS_URL;
    req.httpMethod = Constants.HTTP_METHOD_POST;
    req.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
    String body = returnBody();
    req.addHeader(Constants.CKO_SIGNATURE, getSignature(body));
    req.requestBody = Blob.valueOf(body);

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.setMock(HttpCalloutMock.class, new PostNotificationMock());

    Test.startTest();
    CheckoutNotificationListener.handlePost();
    Test.stopTest();

    System.assertEquals(
      200,
      RestContext.response.statusCode,
      Constants.WRONG_STATUS_CODE
    );
  }

  @isTest
  private static void testStatus500() {
    RestRequest req = new RestRequest();
    req.requestURI = DEFAULT_NOTIFICATIONS_URL;
    req.httpMethod = Constants.HTTP_METHOD_POST;
    req.addHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
    String body = '<xml/>';
    req.addHeader(Constants.CKO_SIGNATURE, getSignature(body));
    req.requestBody = Blob.valueOf(body);
    req.requestBody = Blob.valueOf(body);

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.setMock(HttpCalloutMock.class, new PostNotificationWithoutBodyMock());

    Test.startTest();
    CheckoutNotificationListener.handlePost();
    Test.stopTest();

    System.assertEquals(
      500,
      RestContext.response.statusCode,
      Constants.WRONG_STATUS_CODE
    );
  }

  private static string returnPaymentBody() {
    Map<String, Object> respBody = new Map<String, Object>{
      'amount' => '45.00',
      'status' => Enums.PaymentDetailStatus.CAPTURED
    };

    return JSON.serialize(respBody);
  }

  public static String getSignature(String body) {
    Blob hmac = Crypto.generateMac(
      Constants.HMAC_SHA256,
      Blob.valueOf(body),
      Blob.valueOf(Constants.WEBHOOK_TEST_SECRET_KEY)
    );
    return EncodingUtil.convertToHex(hmac);
  }

  private class PostNotificationMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      request.setMethod(Constants.HTTP_METHOD_POST);
      request.setEndpoint('callout:notification_url');
      request.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

      response.setStatusCode(200);
      response.setBody(returnPaymentBody());

      return response;
    }
  }

  private class PostNotificationWithoutBodyMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      request.setMethod(Constants.HTTP_METHOD_POST);
      request.setEndpoint('callout:notification_url');
      request.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

      return null;
    }
  }
}
