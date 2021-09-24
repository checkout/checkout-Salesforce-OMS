/**
 * @description       : Queries for Order Summary
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 04-08-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0  04-08-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class OrderItemSummaryQuery {
  /**
   * @description Load Order Summary by OrderSummaryId
   * @author roberto.ehlert@osf.digital | 04-08-2021
   * @param orderSummaryId
   * @return OrderItemSummary
   **/

  public List<OrderItemSummary> loadByOrderSummaryId(String orderSummaryId) {
    if (String.isBlank(orderSummaryId)) {
      throw new SalesforceValidationException(
        Constants.ORDER_SUMMARY_NOT_FOUND
      );
    }

    return Utils.validateFieldSecurity(
        OrderItemSummary.class.getName(),
        new List<String>{
          'Name',
          'Quantity',
          'UnitPrice',
          'TotalLineTaxAmount',
          'TotalPrice',
          'TotalTaxAmount'
        },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT
            Name,
            Quantity,
            UnitPrice,
            TotalLineTaxAmount,
            TotalPrice,
            TotalTaxAmount
          FROM OrderItemSummary
          WHERE OrderSummaryId = :orderSummaryId
        ]
      : null;
  }
}
