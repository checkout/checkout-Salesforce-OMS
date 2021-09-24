/**
 * @description       : Queries for Payment Authorization
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-10-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0  03-10-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class PaymentAuthorizationQuery {
  /**
   * @description Load Payment Authorization by payment authorization id
   * @author robeto.ehlert@osf.digital | 03-10-2021
   * @param paymentAuthorizationId
   * @return PaymentAuthorization
   **/
  public PaymentAuthorization loadById(String paymentAuthorizationId) {
    if (String.isBlank(paymentAuthorizationId)) {
      throw new SalesforceValidationException(
        Constants.PAYMENT_AUTHORIZATION_ID_MISSING
      );
    }

    PaymentAuthorization[] paymentAuthorizations = Utils.validateFieldSecurity(
        PaymentAuthorization.class.getName(),
        new List<String>{ 'GatewayRefNumber', 'OrderPaymentSummaryId' },
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
            GatewayRefNumber,
            OrderPaymentSummaryId,
            OrderPaymentSummary.OrderSummaryId,
            OrderPaymentSummary.OrderSummary.OrderNumber
          FROM PaymentAuthorization
          WHERE Id = :paymentAuthorizationId
          LIMIT 1
        ]
      : null;

    if (paymentAuthorizations.isEmpty()) {
      throw new SalesforceValidationException(
        Constants.PAYMENT_AUTHORIZATION_NOT_FOUND
      );
    }

    return paymentAuthorizations[0];
  }

  public PaymentAuthorization loadByGatewayRefNumber(String gatewayRefNumber) {
    if (String.isBlank(gatewayRefNumber)) {
      throw new SalesforceValidationException(
        Constants.GATEWAY_REF_NUMBER_MISSING
      );
    }

    PaymentAuthorization[] paymentAuthorizations = Utils.validateFieldSecurity(
        PaymentAuthorization.class.getName(),
        new List<String>{ 'GatewayRefNumber' },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT GatewayRefNumber
          FROM PaymentAuthorization
          WHERE GatewayRefNumber = :gatewayRefNumber
          LIMIT 1
        ]
      : null;
    if (paymentAuthorizations.isEmpty()) {
      throw new SalesforceValidationException(
        Constants.PAYMENT_AUTHORIZATION_NOT_FOUND
      );
    }

    return paymentAuthorizations[0];
  }
}
