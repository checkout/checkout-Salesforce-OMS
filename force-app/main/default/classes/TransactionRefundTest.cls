@isTest
public with sharing class TransactionRefundTest {
  private static final String GATEWAY_REFERENCE_NUMBER = '999999';

  @isTest
  static void getRequestTestSuccess() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('RefundPaymentResponse');
    mock.setStatusCode(202);
    mock.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

    Payment payment = new Payment(
      Amount = 99,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      Type = Enums.PaymentType.CAPTURE.name(),
      ProcessingMode = Enums.ProcessingMode.EXTERNAL.name()
    );

    payment.GatewayRefNumber = GATEWAY_REFERENCE_NUMBER;

    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 100,
      GatewayRefNumber = GATEWAY_REFERENCE_NUMBER,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL'
    );
    insert paymentAuthorization;

    payment.PaymentAuthorizationId = paymentAuthorization.id;
    insert payment;

    Test.startTest();

    Test.setMock(HttpCalloutMock.class, mock);
    TransactionRefund refundRequest = new TransactionRefund();
    refundRequest.paymentId = payment.id;
    refundRequest.amount = 99;
    HttpRequest request = refundRequest.getRequest();
    System.assertEquals(
      request.getMethod(),
      Constants.HTTP_METHOD_POST,
      Constants.INVALID_HTTP_METHOD
    );

    String relativeUrl = DomainConstants.getCheckoutUrl(
      Enums.CheckoutRequestType.REFUND
    );
    String uri = String.format(
      relativeUrl,
      new List<String>{ GATEWAY_REFERENCE_NUMBER }
    );

    System.assertEquals(request.getEndpoint(), uri, Constants.INVALID_ENDPOINT);
    Test.StopTest();
  }

  @isTest
  static void getRequestExceptionBlankPaymentId() {
    TransactionRefund transactionRefund = new TransactionRefund();
    try {
      transactionRefund.paymentId = '';
      transactionRefund.getRequest();
    } catch (SalesforceValidationException e) {
      System.assertEquals(
        Constants.PAYMENT_ID_MISSING,
        e.getMessage(),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }

  @isTest
  static void getRequestExceptionMissingGatewayRefNumber() {
    Payment payment = new Payment(
      Amount = 99,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      Type = Enums.PaymentType.CAPTURE.name(),
      ProcessingMode = Enums.ProcessingMode.EXTERNAL.name()
    );
    insert payment;
    try {
      Test.startTest();
      TransactionRefund transactionRefund = new TransactionRefund();
      transactionRefund.paymentId = payment.id;
      transactionRefund.amount = 99;
      transactionRefund.getRequest();
      Test.stopTest();
    } catch (SalesforceValidationException e) {
      System.assert(
        e.getMessage().equals(Constants.GATEWAY_REF_NUMBER_MISSING),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }
}
