@isTest
private class CheckoutNotificationHandlerTest {
  @isTest
  private static void getPaymentTest() {
    WebhookResponse responseData = new WebhookResponse();
    responseData.data = new WebhookResponse.Data();

    Test.setMock(HttpCalloutMock.class, new PostNotificationMock());

    responseData.type = Enums.WebhookRequestType.PAYMENT_CAPTURED;
    responseData.data.id = 'pay_12';
    responseData.data.amount = 45;

    HttpResponse response = CheckoutNotificationHandler.getNotificationResponseFromAdapter(
      responseData
    );

    System.assertEquals(
      200,
      response.getStatusCode(),
      Constants.WRONG_STATUS_CODE
    );
    System.assertEquals(
      returnBody(),
      response.getBody(),
      Constants.INVALID_BODY
    );
  }

  private static string returnBody() {
    Map<String, Object> respBody = new Map<String, Object>{
      'amount' => '45.00',
      'status' => Enums.PaymentDetailStatus.CAPTURED
    };

    return JSON.serialize(respBody);
  }

  private class PostNotificationMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      request.setMethod(Constants.HTTP_METHOD_POST);
      request.setEndpoint('callout:notification_url');
      request.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

      response.setStatusCode(200);
      response.setBody(returnBody());

      return response;
    }
  }
}
