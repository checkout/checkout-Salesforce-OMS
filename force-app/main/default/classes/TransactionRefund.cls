/**
 * @description       : Prepare Refund payment Checkout
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-10-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-10-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class TransactionRefund extends BaseRequest {
  public Double amount;
  public String orderNumber;
  public String paymentId;

  public override HttpRequest getRequest() {
    if (String.IsBlank(paymentId)) {
      throw new SalesforceValidationException(Constants.PAYMENT_ID_MISSING);
    }

    Payment payment = new PaymentQuery().loadById(paymentId);

    if (String.IsBlank(payment.GatewayRefNumber)) {
      throw new SalesforceValidationException(
        Constants.GATEWAY_REF_NUMBER_MISSING
      );
    }

    String secretKey = CheckoutPaymentConfigQuery.getSecretKey();
    String relativeUrl = DomainConstants.getCheckoutUrl(
      Enums.CheckoutRequestType.REFUND
    );
    String uri = String.format(
      relativeUrl,
      new List<String>{ payment.GatewayRefNumber }
    );

    String orderNumber = payment.OrderPaymentSummary.OrderSummary.OrderNumber;

    TransactionBody body = TransactionBody.getInstance();
    String bodyContent = body.getBody(amount, orderNumber);

    return CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_POST,
      uri,
      bodyContent,
      secretKey
    );
  }
}
