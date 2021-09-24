@isTest
private class PaymentAuthorizationQueryTest {
  @isTest
  static void loadByIdMissingPaymentAuthorizationIdTest() {
    try {
      new PaymentAuthorizationQuery().loadById('');
    } catch (Exception e) {
      System.assert(
        e.getMessage().equals(Constants.PAYMENT_AUTHORIZATION_ID_MISSING),
        (Constants.PAYMENT_AUTHORIZATION_ID_MISSING)
      );
    }
  }

  @isTest
  static void loadByIdSuccess() {
    Exception testException;
    PaymentAuthorization loadedPaymentAuthorization;
    PaymentAuthorization paymentAuthorization;
    try {
      paymentAuthorization = new PaymentAuthorization(
        Amount = 100,
        Status = 'PROCESSED',
        ProcessingMode = 'EXTERNAL'
      );
      insert paymentAuthorization;

      loadedPaymentAuthorization = new PaymentAuthorizationQuery()
        .loadById(paymentAuthorization.Id);
    } catch (Exception e) {
      testException = e;
    }
    System.assert(
      loadedPaymentAuthorization.id == paymentAuthorization.id,
      Constants.REQUEST_PROCESSED
    );
    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void loadByIdWrongPaymentAuthorizationIdTest() {
    try {
      new PaymentAuthorizationQuery().loadById('dummy id');
    } catch (Exception e) {
      System.assert(
        e.getMessage().equals(Constants.PAYMENT_AUTHORIZATION_NOT_FOUND),
        Constants.PAYMENT_AUTHORIZATION_NOT_FOUND
      );
    }
  }

  @isTest
  static void loadByGatewayRefNumberSuccess() {
    Exception testException;
    String gatewayReferenceNumber = '111';
    PaymentAuthorization paymentAuthorization = new PaymentAuthorization(
      Amount = 100,
      GatewayRefNumber = gatewayReferenceNumber,
      Status = Enums.PaymentStatus.PROCESSED.name(),
      ProcessingMode = 'EXTERNAL'
    );
    insert paymentAuthorization;

    Test.startTest();
    try {
      new PaymentAuthorizationQuery()
        .loadByGatewayRefNumber(gatewayReferenceNumber);
    } catch (SalesforceValidationException e) {
      testException = e;
    }

    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }

  @isTest
  static void loadByGatewayRefNumberFail() {
    string gatewayRefNumber = '111';
    try {
      new PaymentAuthorizationQuery().loadByGatewayRefNumber(gatewayRefNumber);
    } catch (SalesforceValidationException e) {
      System.assertEquals(
        Constants.PAYMENT_AUTHORIZATION_NOT_FOUND,
        e.getMessage(),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }

  @isTest
  static void loadByGatewayRefNumberMissing() {
    string gatewayRefNumber = '';
    try {
      new PaymentAuthorizationQuery().loadByGatewayRefNumber(gatewayRefNumber);
    } catch (SalesforceValidationException e) {
      System.assertEquals(
        Constants.GATEWAY_REF_NUMBER_MISSING,
        e.getMessage(),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }
}
