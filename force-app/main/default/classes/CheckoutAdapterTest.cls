/**
 * @description       : unit tests for CheckoutAdapter
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-11-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-11-2021   roberto.ehlert@osf.digital   Initial Version
 **/

@isTest
private class CheckoutAdapterTest {
  @isTest(SeeAllData=true)
  static void doTransactionCaptureFail() {
    Exception testException;
    String dummyId = '999';

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpCaptureResponseGeneratorFail()
    );

    commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      99,
      dummyId
    );

    try {
      PaymentAuthorization paymentAuthorization = new PaymentAuthorizationQuery()
        .loadById(CreateData.initializeAndReturnPaymentAuthorization());

      captureRequest.paymentAuthorizationId = paymentAuthorization.id;

      Test.startTest();
      new CheckoutAdapter()
        .doTransactionCapture(
          captureResponse,
          captureRequest,
          paymentAuthorization,
          Enums.PaymentMethod.KLARNA.name()
        );
      Test.stopTest();
    } catch (SalesforceValidationException e) {
      testException = e;
    }

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest(SeeAllData=true)
  static void doTransactionCaptureTest() {
    Exception testException;
    String dummyId = '999';

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpCaptureResponseGeneratorSuccess()
    );

    commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      899,
      dummyId
    );

    try {
      PaymentAuthorization paymentAuthorization = new PaymentAuthorizationQuery()
        .loadById(CreateData.initializeAndReturnPaymentAuthorization());

      captureRequest.paymentAuthorizationId = paymentAuthorization.id;

      Test.startTest();
      new CheckoutAdapter()
        .doTransactionCapture(
          captureResponse,
          capturerequest,
          paymentAuthorization,
          Enums.PaymentMethod.KLARNA.name()
        );
      Test.stopTest();
    } catch (SalesforceValidationException e) {
      testException = e;
    }

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void getDetailsPaymentSuccessTest() {
    Exception testException;
    String gatewayReferenceNumber = '999';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpPaymentDetailsResponseGeneratorSuccess()
    );

    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 100,
      GatewayRefNumber = gatewayReferenceNumber,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL'
    );
    insert paymentAuthorization;

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      paymentAuthorization.Id
    );
    captureRequest.amount = 100;

    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    Test.startTest();
    try {
      new CheckoutAdapter()
        .createCaptureResponse(
          (commercepayments.CaptureRequest) context.getPaymentRequest()
        );
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest(SeeAllData=true)
  static void getDetailsPaymentNotCapturedTest() {
    Exception testException;

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpPaymentDetailsResponseNotCapturedGenerator()
    );

    PaymentAuthorization paymentAuthorization = new PaymentAuthorizationQuery()
      .loadById(CreateData.initializeAndReturnPaymentAuthorization());

    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      paymentAuthorization.Id
    );
    captureRequest.amount = 100;
    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    Test.startTest();
    try {
      new CheckoutAdapter()
        .createCaptureResponse(
          (commercepayments.CaptureRequest) context.getPaymentRequest()
        );
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void captureRequestSuccessTest() {
    Exception testException;
    String dummyId = '999';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpCaptureResponseGeneratorSuccess()
    );
    CheckoutAdapter checkoutAdapter = new CheckoutAdapter();
    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      899,
      dummyId
    );
    captureRequest.amount = 899.39;
    captureRequest.paymentAuthorizationId = dummyId;
    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    Test.startTest();
    try {
      checkoutAdapter.processRequest(context);
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();
    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void captureRequestFailTest() {
    Exception testException;
    String dummyId = '999';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpCaptureResponseGeneratorFail()
    );
    CheckoutAdapter checkoutAdapter = new CheckoutAdapter();
    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      899,
      dummyId
    );
    captureRequest.amount = 899.39;
    captureRequest.paymentAuthorizationId = dummyId;
    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    Test.startTest();
    try {
      checkoutAdapter.processRequest(context);
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void refundRequestSuccessTest() {
    String gatewayReferenceNumber = '999999';

    Exception testException;
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpRefundResponseGeneratorSuccess()
    );
    CheckoutAdapter checkoutAdapter = new CheckoutAdapter();

    Payment payment = new Payment(
      Amount = 100,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      Type = Enums.PaymentType.CAPTURE.name(),
      ProcessingMode = Enums.ProcessingMode.EXTERNAL.name()
    );

    payment.GatewayRefNumber = gatewayReferenceNumber;

    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 100,
      GatewayRefNumber = gatewayReferenceNumber,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL'
    );
    insert paymentAuthorization;

    payment.PaymentAuthorizationId = paymentAuthorization.Id;
    insert payment;

    commercepayments.ReferencedRefundRequest request = new commercepayments.ReferencedRefundRequest(
      100,
      payment.Id
    );

    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      request,
      commercepayments.RequestType.ReferencedRefund
    );
    Test.startTest();
    try {
      checkoutAdapter.createRefundResponse(
        (commercepayments.ReferencedRefundRequest) context.getPaymentRequest()
      );
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void refundRequestDeclinedTest() {
    String gatewayReferenceNumber = '999999';

    Exception testException;
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpCaptureResponseGeneratorFail()
    );
    CheckoutAdapter checkoutAdapter = new CheckoutAdapter();

    Payment payment = new Payment(
      Amount = 100,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      Type = Enums.PaymentType.CAPTURE.name(),
      ProcessingMode = Enums.ProcessingMode.EXTERNAL.name()
    );

    payment.GatewayRefNumber = gatewayReferenceNumber;

    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 100,
      GatewayRefNumber = gatewayReferenceNumber,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL'
    );
    insert paymentAuthorization;

    payment.PaymentAuthorizationId = paymentAuthorization.Id;
    insert payment;

    commercepayments.ReferencedRefundRequest request = new commercepayments.ReferencedRefundRequest(
      100,
      payment.Id
    );

    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      request,
      commercepayments.RequestType.ReferencedRefund
    );
    Test.startTest();
    try {
      checkoutAdapter.createRefundResponse(
        (commercepayments.ReferencedRefundRequest) context.getPaymentRequest()
      );
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void processRequestGatewayError() {
    commercepayments.ReferencedRefundRequest request = new commercepayments.ReferencedRefundRequest(
      899,
      '123'
    );

    CommercePayments.PaymentGatewayContext context = new CommercePayments.PaymentGatewayContext(
      request,
      commercepayments.RequestType.ReferencedRefund
    );
    CheckoutAdapter adapter = new CheckoutAdapter();

    try {
      adapter.processRequest(context);
    } catch (SalesforceValidationException e) {
      System.assertEquals(
        '400',
        e.getMessage(),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }

  @isTest
  static void processCaptureRequestMissingAmount() {
    String dummyId = '999';
    CheckoutAdapter checkoutAdapter = new CheckoutAdapter();
    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      null,
      dummyId
    );
    captureRequest.paymentAuthorizationId = dummyId;
    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    Test.startTest();
    try {
      checkoutAdapter.processRequest(context);
    } catch (Exception e) {
      System.assertEquals(
        Constants.REQUIRED_FIELD_MISSING_AMOUNT,
        e.getMessage(),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
    Test.stopTest();
  }

  @isTest
  static void processNullResponse() {
    Exception testException;
    String gatewayReferenceNumber = '999';
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpNullResponseGeneratorFail()
    );

    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 100,
      GatewayRefNumber = gatewayReferenceNumber,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL'
    );
    insert paymentAuthorization;

    CheckoutAdapter checkoutAdapter = new CheckoutAdapter();
    commercepayments.CaptureRequest captureRequest = new commercepayments.CaptureRequest(
      100,
      paymentAuthorization.Id
    );
    captureRequest.amount = 100;
    commercepayments.PaymentGatewayContext context = new commercepayments.PaymentGatewayContext(
      captureRequest,
      commercepayments.RequestType.Capture
    );

    Test.startTest();
    try {
      checkoutAdapter.createCaptureResponse(
        (commercepayments.CaptureRequest) context.getPaymentRequest()
      );
    } catch (Exception e) {
      testException = e;
    }
    Test.stopTest();

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void processCaptureNotificationTest() {
    commercepayments.BaseNotification notification = new commercepayments.CaptureNotification();
    notification.setAmount(15);
    notification.setStatus(commercepayments.NotificationStatus.Success);
    notification.setGatewayReferenceNumber('45');
    notification.setGatewayDate(system.now());

    CheckoutAdapter adapter = new CheckoutAdapter();

    commercepayments.BaseNotification processedNotification = adapter.processNotificationResponse(
      returnWebhookResponseBody(Enums.WebhookRequestType.PAYMENT_CAPTURED)
    );

    System.assertEquals(
      notification.ToString(),
      processedNotification.ToString(),
      'Notification data is wrong'
    );
  }

  @isTest
  static void processpaymentRefundDeclinedNotificationTest() {
    commercepayments.BaseNotification notification = new commercepayments.ReferencedRefundNotification();
    notification.setAmount(15);
    notification.setStatus(commercepayments.NotificationStatus.Failed);
    notification.setGatewayReferenceNumber('45');
    notification.setGatewayDate(system.now());
    CheckoutAdapter adapter = new CheckoutAdapter();

    commercepayments.BaseNotification processedNotification = adapter.processNotificationResponse(
      returnWebhookResponseBody(
        Enums.WebhookRequestType.PAYMENT_REFUND_DECLINED
      )
    );

    System.assertEquals(
      notification.ToString(),
      processedNotification.ToString(),
      'Notification data is wrong'
    );
  }

  private static Blob returnWebhookResponseBody(Enums.WebhookRequestType type) {
    Map<String, Object> respBody = new Map<String, Object>{
      'data' => new Map<String, Object>{ 'amount' => 1500, 'id' => 45 },
      'type' => type
    };

    return Blob.valueOf(JSON.serialize(respBody));
  }

  public class MockHttpRefundResponseGeneratorSuccess implements HttpCalloutMock {
    /**
     * @description create success response for Capture payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      // Optionally, only send a mock response for a specific endpoint and method.
      System.assertEquals(
        Constants.HTTP_METHOD_POST,
        req.getMethod(),
        Constants.INVALID_HTTP_METHOD
      );

      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      res.setBody(getBodyJson());
      res.setStatusCode(202);
      return res;
    }

    public String getBodyJson() {
      return '{"action_id":"act_y3oqhf46pyzuxjbcn2giaqnb44",' +
        '"reference":"ORD-5023-4E89","' +
        '_links":{"payment":{"href":"https://api.sandbox.checkout.com/payments/pay_kladqdb6hm5ebggtq45rtzjati"}}}';
    }
  }

  public class MockHttpRefundResponseGeneratorFail implements HttpCalloutMock {
    /**
     * @description create fail response for refund payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      // Optionally, only send a mock response for a specific endpoint and method.
      System.assertEquals(
        Constants.HTTP_METHOD_POST,
        req.getMethod(),
        Constants.INVALID_HTTP_METHOD
      );

      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      //res.setBody(null);
      res.setStatusCode(502);
      return res;
    }
  }

  public class MockHttpPaymentDetailsResponseGeneratorSuccess implements HttpCalloutMock {
    /**
     * @description create success response for Capture payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      // Optionally, only send a mock response for a specific endpoint and method.
      System.assertEquals(
        Constants.HTTP_METHOD_GET,
        req.getMethod(),
        Constants.INVALID_HTTP_METHOD
      );

      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      res.setBody(getBodyJson());
      res.setStatusCode(200);
      return res;
    }

    public String getBodyJson() {
      return '{' +
        '"id": "pay_y3oqhf46pyzuxjbcn2giaqnb44",' +
        '"source": {' +
        '"type": "klarna"' +
        '},' +
        '"amount": 100,' +
        '"reference": "ORD-5023-4E89",' +
        '"approved": true,' +
        '"status": "captured"' +
        '}';
    }
  }

  public class MockHttpPaymentDetailsResponseNotCapturedGenerator implements HttpCalloutMock {
    /**
     * @description create success response for Capture payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      // Optionally, only send a mock response for a specific endpoint and method.

      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      res.setBody(getBodyJson());
      res.setStatusCode(200);
      return res;
    }

    public String getBodyJson() {
      return '{"id":"pay_y3oqhf46pyzuxjbcn2giaqnb44",' +
        '"source": {' +
        '"type": "visa"' +
        '},' +
        '"amount": 100,' +
        '"reference":"ORD-5023-4E89",' +
        '"approved": true,' +
        '"status": "Authorized"}';
    }
  }

  public class MockHttpCaptureResponseGeneratorSuccess implements HttpCalloutMock {
    /**
     * @description create success response for Capture payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      System.assertEquals(
        Constants.HTTP_METHOD_POST,
        req.getMethod(),
        Constants.INVALID_HTTP_METHOD
      );

      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      res.setBody(getBodyJson());
      res.setStatusCode(202);
      return res;
    }

    public String getBodyJson() {
      return '{"action_id":"act_3kfr4betasbelhjdk346yutxvu",' +
        '"reference":"ORD-5023-4E89","' +
        '_links":{"payment":{"href":"https://api.sandbox.checkout.com/payments/pay_kladqdb6hm5ebggtq45rtzjati"}}}';
    }
  }

  public class MockHttpCaptureResponseGeneratorFail implements HttpCalloutMock {
    /**
     * @description create fail response for Capture payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      res.setBody(getBodyJson());
      res.setStatusCode(422);
      return res;
    }

    public String getBodyJson() {
      return '{"request_id":"0HL80RJLS76I7","error_type":"request_invalid","error_codes":["payment_source_required"]}';
    }
  }

  public class MockHttpNullResponseGeneratorFail implements HttpCalloutMock {
    /**
     * @description create fail response for Capture payment
     * @author roberto.ehlert@osf.digital | 03-11-2021
     * @param req
     * @return HTTPResponse
     **/
    public HTTPResponse respond(HTTPRequest req) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);
      res.setBody(getBodyJson());
      res.setStatusCode(502);
      return res;
    }

    public String getBodyJson() {
      return '';
    }
  }
}
