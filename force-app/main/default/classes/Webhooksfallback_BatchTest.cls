@isTest
private class Webhooksfallback_BatchTest {
  @TestSetup
  static void makeData() {
    Payment paymentRecord = new Payment();

    paymentRecord.Amount = 45;
    paymentRecord.Status = Enums.PaymentStatus.DRAFT.name();
    paymentRecord.Type = Enums.PaymentType.CAPTURE.name();
    paymentRecord.ProcessingMode = Enums.ProcessingMode.EXTERNAL.name();
    paymentRecord.GatewayRefNumber = 'pay_try456';

    insert paymentRecord;
  }

  @isTest
  private static void changePaymentStatusTest() {
    Test.setMock(HttpCalloutMock.class, new CapturedPaymentMock());

    Payment paymentRecord = [
      SELECT Status, GatewayRefNumber, OrderPaymentSummaryId, PaymentGatewayId
      FROM Payment
      LIMIT 1
    ];

    Test.startTest();
    new Webhooksfallback_Batch()
      .execute(null, new List<Payment>{ paymentRecord });
    Test.stopTest();

    System.assertEquals(
      Enums.PaymentStatus.PROCESSED.name(),
      paymentRecord.Status,
      'The status should be changed'
    );
  }

  @isTest
  private static void exceptionTest() {
    Test.setMock(HttpCalloutMock.class, new InvalidBodyMock());

    Payment paymentRecord = [
      SELECT Status, GatewayRefNumber, OrderPaymentSummaryId, PaymentGatewayId
      FROM Payment
      LIMIT 1
    ];

    Test.startTest();
    new Webhooksfallback_Batch()
      .execute(null, new List<Payment>{ paymentRecord });
    Test.stopTest();

    System.assertEquals(
      1,
      [SELECT COUNT() FROM Exception_Log__c],
      'A exception should be thrown'
    );
  }

  @isTest
  private static void dontChangePaymentStatusTest() {
    Test.setMock(HttpCalloutMock.class, new Reponse400Mock());

    Payment paymentRecord = [
      SELECT Status, GatewayRefNumber, OrderPaymentSummaryId, PaymentGatewayId
      FROM Payment
      LIMIT 1
    ];

    Test.startTest();
    new Webhooksfallback_Batch()
      .execute(null, new List<Payment>{ paymentRecord });
    Test.stopTest();

    System.assertEquals(
      Enums.PaymentStatus.DRAFT.name().toLowerCase(),
      paymentRecord.Status.toLowerCase(),
      'The status should be changed'
    );
  }

  @isTest
  private static void contructorTest() {
    Test.startTest();
    Webhooksfallback_Batch paymentStatusBatch = new Webhooksfallback_Batch();
    Database.executeBatch(paymentStatusBatch);
    Test.stopTest();

    // make a dummy asert since we cannot create Payment objects with Pending status
    List<Payment> paymentRecord = [SELECT Status FROM Payment];
    System.assertEquals(1, paymentRecord.size(), 'Should be one payment');
  }

  private static String returnBody() {
    Map<String, Object> respBody = new Map<String, Object>{
      'id' => 'pay_try456',
      'amount' => '45',
      'status' => 'Captured'
    };

    return JSON.serialize(respBody);
  }

  private class CapturedPaymentMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      request.setMethod(Constants.HTTP_METHOD_GET);
      request.setEndpoint('GetPaymentResponse');
      request.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

      response.setStatusCode(200);
      response.setBody(returnBody());

      return response;
    }
  }

  private class InvalidBodyMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      request.setMethod(Constants.HTTP_METHOD_GET);
      request.setEndpoint('GetPaymentResponse');
      request.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

      response.setStatusCode(200);
      response.setBody('<hml8/*>');

      return response;
    }
  }

  private class Reponse400Mock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();

      response.setStatusCode(400);

      return response;
    }
  }
}
