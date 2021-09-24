@isTest
private class ShipmentQueryTest {
  @isTest
  static void loadByIdMissingOrderSummaryId() {
    try {
      new ShipmentQuery().loadByOrderSummaryId('');
    } catch (SalesforceValidationException e) {
      System.assert(e.getMessage().equals(Constants.ORDER_SUMMARY_NOT_FOUND));
    }
  }
}
