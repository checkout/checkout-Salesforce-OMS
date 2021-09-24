/**
 * @description       : Object for GetPayment Response
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-29-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-17-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class TransactionGetPayment extends BaseRequest {
  public String paymentRefId;
  private String secretKey;

  public TransactionGetPayment() {
    secretKey = CheckoutPaymentConfigQuery.getSecretKey();
  }

  public TransactionGetPayment(string secretKey, string paymentRefId) {
    this.secretKey = secretKey;
    this.paymentRefId = paymentRefId;
  }

  public override HttpRequest getRequest() {
    if (String.isBlank(paymentRefId)) {
      throw new SalesforceValidationException(
        Constants.GATEWAY_REF_NUMBER_MISSING
      );
    }

    String relativeUrl = DomainConstants.getCheckoutUrl(
      Enums.CheckoutRequestType.GET_DETAILS
    );

    String uri = String.format(relativeUrl, new List<String>{ paymentRefId });

    return CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_GET,
      uri,
      null,
      secretKey
    );
  }
}
