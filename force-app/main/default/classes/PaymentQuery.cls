/**
 * @description       : Payment queries
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-12-2021   roberto.ehlert@osf.digital   Initial Version
 **/
public with sharing class PaymentQuery {
  /**
   * @description Return payment for a specific payment id
   * @author roberto.ehlert@osf.digital | 03-12-2021
   * @return Payment
   **/
  public Payment loadById(String paymentId) {
    if (String.isBlank(paymentId)) {
      throw new SalesforceValidationException(Constants.PAYMENT_ID_MISSING);
    }

    Payment[] payments = Utils.validateFieldSecurity(
        Payment.class.getName(),
        new List<String>{ 'PaymentAuthorizationId', 'GatewayRefNumber' },
        Constants.IS_ACCESSIBLE
      ) &&
      Utils.validateFieldSecurity(
        OrderPaymentSummary.class.getName(),
        new List<String>{ 'OrderSummaryId' },
        Constants.IS_ACCESSIBLE
      ) &&
      Utils.validateFieldSecurity(
        OrderSummary.class.getName(),
        new List<String>{ 'OrderNumber' },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT
            PaymentAuthorizationId,
            GatewayRefNumber,
            OrderPaymentSummary.OrderSummaryId,
            OrderPaymentSummary.OrderSummary.OrderNumber
          FROM Payment
          WHERE ID = :paymentId
          LIMIT 1
        ]
      : null;

    if (payments.isEmpty()) {
      throw new SalesforceValidationException(Constants.PAYMENT_NOT_FOUND);
    }

    return payments[0];
  }
}
