/**
 * @description       : Queries for Shipment
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 04-09-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0  04-08-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class ShipmentQuery {
  /**
   * @description Load Payment Summary by OrderPaymentSummaryId
   * @author roberto.ehlert@osf.digital | 04-09-2021
   * @param orderPaymentSummaryId
   * @return Shipment
   **/

  public List<Shipment> loadByOrderSummaryId(String orderSummaryId) {
    if (String.isBlank(orderSummaryId)) {
      throw new SalesforceValidationException(
        Constants.ORDER_SUMMARY_NOT_FOUND
      );
    }

    return Utils.validateFieldSecurity(
        OrderDeliveryMethod.class.getName(),
        new List<String>{ 'Name' },
        Constants.IS_ACCESSIBLE
      ) &&
      Utils.validateFieldSecurity(
        Shipment.class.getName(),
        new List<String>{ 'Provider', 'TrackingUrl', 'TrackingNumber' },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT Provider, DeliveryMethod.Name, TrackingUrl, TrackingNumber
          FROM Shipment
          WHERE OrderSummaryId = :orderSummaryId
        ]
      : null;
  }
}
