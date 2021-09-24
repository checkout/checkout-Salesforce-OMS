/**
 * @description       : Test capture payment Checkout
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-17-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-17-2021   roberto.ehlert@osf.digital   Initial Version
 **/
@isTest
private class TransactionCaptureTest {
  private static final String GATEWAY_REFERENCE_NUMBER = '999999';

  @isTest
  static void getRequestShouldSuccess() {
    OrderSummary summ = new OrderSummary();
    summ.OrderNumber = 'ORD-123';
    TransactionCapture captureRequest = new TransactionCapture();
    captureRequest.orderSummaryObj = summ;
    captureRequest.amount = 99;
    captureRequest.gatewayRefNumber = GATEWAY_REFERENCE_NUMBER;
    captureRequest.paymentType = Enums.CheckoutRequestType.CAPTURE.name();

    HttpRequest request = captureRequest.getRequest();
    System.assertEquals(
      request.getMethod(),
      Constants.HTTP_METHOD_POST,
      Constants.INVALID_HTTP_METHOD
    );
  }

  @isTest
  static void getRequestKlarnaTestShouldSuccess() {
    PaymentAuthorizationQuery query = new PaymentAuthorizationQuery();
    PaymentAuthorization paymentAuthorization = query.loadById(
      CreateData.initializeAndReturnPaymentAuthorization()
    );
    TransactionCapture captureRequest = new TransactionCapture();
    captureRequest.paymentType = Enums.PaymentMethod.KLARNA.name();
    captureRequest.amount = 99;
    captureRequest.orderSummaryObj = paymentAuthorization.OrderPaymentSummary.OrderSummary;

    captureRequest.gatewayRefNumber = GATEWAY_REFERENCE_NUMBER;
    HttpRequest request = captureRequest.getRequest();
    System.assertEquals(
      request.getEndpoint(),
      '/klarna-external/orders/999999/captures',
      Constants.INVALID_ENDPOINT
    );
    KlarnaDetails klarnaDetails = (KlarnaDetails) JSON.deserialize(
      request.getBody(),
      KlarnaDetails.class
    );
    System.assert(klarnaDetails != null, Constants.REQUEST_PROCESSED);
  }
}
