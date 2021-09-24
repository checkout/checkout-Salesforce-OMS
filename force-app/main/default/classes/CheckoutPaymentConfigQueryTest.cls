@isTest
private class CheckoutPaymentConfigQueryTest {
  @isTest(seeAllData=true)
  static void getKlarnaSettingsShouldSuccess() {
    Exception assertedException;
    Klarna_Setting__mdt myKlarnaConfigs;
    try {
      myKlarnaConfigs = CheckoutPaymentConfigQuery.getKlarnaSettings();
    } catch (SalesforceValidationException e) {
      assertedException = e;
    }
    System.assertEquals(null, assertedException, Constants.REQUEST_PROCESSED);
    System.assert(myKlarnaConfigs != null, Constants.REQUEST_PROCESSED);
  }
}
