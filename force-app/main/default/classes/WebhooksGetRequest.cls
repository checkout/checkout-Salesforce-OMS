/**
 * @description       : Create get request of the webhook endpoint
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-12-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhooksGetRequest extends BaseRequest {
  private String secretKey;

  public WebhooksGetRequest(String secretKey) {
    this.secretKey = secretKey;
  }

  /**
   * @description create and return the get HttpRequest for the webhooks
   * @author rafal.nascimento@osf.digital | 03-12-2021
   * @return HttpRequest
   **/
  public override HttpRequest getRequest() {
    String uri = DomainConstants.getCheckoutUrl(
      Enums.CheckoutRequestType.WEBHOOK
    );

    return CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_GET,
      uri,
      null,
      secretKey
    );
  }
}
