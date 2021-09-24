@isTest
private class PaymentQueryTest {
  @isTest
  static void loadByIdMissingPaymentIdTest() {
    try {
      new PaymentQuery().loadById('');
    } catch (Exception e) {
      System.assert(
        e.getMessage().equals(Constants.PAYMENT_ID_MISSING),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }
  @isTest
  static void loadByIdSuccess() {
    Exception testException;
    Payment loadedPayment;
    Payment payment;
    try {
      payment = new Payment(
        Amount = 99,
        Status = Enums.PaymentStatus.PROCESSED.name(),
        Type = Enums.PaymentType.CAPTURE.name(),
        ProcessingMode = Enums.ProcessingMode.EXTERNAL.name()
      );
      insert payment;

      loadedPayment = new PaymentQuery().loadById(payment.Id);
    } catch (Exception e) {
      testException = e;
    }
    System.assert(payment.id == loadedPayment.id, Constants.REQUEST_PROCESSED);
    System.assert(testException == null, Constants.REQUEST_PROCESSED);
  }
  @isTest
  static void loadByIdWrongPaymentIdTest() {
    try {
      new PaymentQuery().loadById('dummy id');
    } catch (Exception e) {
      System.assert(
        e.getMessage().equals(Constants.PAYMENT_NOT_FOUND),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }

  @isTest
  static void loadByIdException() {
    try {
      new PaymentQuery().loadById('');
    } catch (SalesforceValidationException e) {
      System.assert(
        e.getMessage().equals(Constants.PAYMENT_ID_MISSING),
        Constants.SALESFORCE_VALIDATION_EXPECTED
      );
    }
  }
}
