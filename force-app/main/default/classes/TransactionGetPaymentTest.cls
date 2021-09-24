/**
 * @description       : Test get payment Checkout
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-17-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-17-2021   roberto.ehlert@osf.digital   Initial Version
 **/
@isTest
private class TransactionGetPaymentTest {
  private static final String GATEWAY_REFERENCE_NUMBER = '999999';

  @isTest
  static void getRequestTestSuccess() {
    Exception testException;

    try {
      PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
        Amount = 100,
        GatewayRefNumber = GATEWAY_REFERENCE_NUMBER,
        Status = Enums.PaymentStatus.PROCESSED.name(),
        ProcessingMode = 'EXTERNAL'
      );
      insert paymentAuthorization;

      Test.startTest();

      TransactionGetPayment getPayment = new TransactionGetPayment();
      getPayment.paymentRefId = paymentAuthorization.Id;
      HttpRequest request = getPayment.getRequest();

      System.assertEquals(
        request.getMethod(),
        Constants.HTTP_METHOD_GET,
        Constants.INVALID_HTTP_METHOD
      );

      String relativeUrl = DomainConstants.getCheckoutUrl(
        Enums.CheckoutRequestType.GET_DETAILS
      );
      String uri = String.format(
        relativeUrl,
        new List<String>{ getPayment.paymentRefId }
      );

      System.assertEquals(
        request.getEndpoint(),
        uri,
        Constants.INVALID_ENDPOINT
      );
      Test.StopTest();
    } catch (Exception e) {
      testException = e;
    }
    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void getRequestMissingPaymentAuthorization() {
    TransactionGetPayment transactionGetPayment = new TransactionGetPayment();
    transactionGetPayment.paymentRefId = '';

    try {
      transactionGetPayment.getRequest();
    } catch (SalesforceValidationException e) {
      System.assert(
        e.getMessage().equals(Constants.GATEWAY_REF_NUMBER_MISSING),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }
}
