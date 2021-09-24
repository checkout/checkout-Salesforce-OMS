@isTest
private class OrderItemSummaryQueryTest {
  @isTest
  static void loadByIdMissingOrderSummaryId() {
    try {
      new OrderItemSummaryQuery().loadByOrderSummaryId('');
    } catch (SalesforceValidationException e) {
      System.assert(e.getMessage().equals(Constants.ORDER_SUMMARY_NOT_FOUND));
    }
  }
}
