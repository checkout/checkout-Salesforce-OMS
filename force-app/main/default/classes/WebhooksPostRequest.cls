/**
 * @description       : Create the post request of webhook endpoint
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhooksPostRequest extends BaseRequest {
  private Checkout_Payment_Config__c config;
  private List<String> eventTypes;

  public WebhooksPostRequest(
    List<String> eventsTypes,
    Checkout_Payment_Config__c config
  ) {
    this.eventTypes = eventsTypes;
    this.config = config;
  }

  /**
   * @description update or insert the active event types
   * @author rafael.nascimento@osf.digital | 03-12-2021
   * @param eventTypes list of the active event types at the org
   * @param config the active Checkout_Payment_Config__c
   * @return A set of the event types name
   **/
  private string createBody() {
    WebhooksWrapper webhooks = new WebhooksWrapper();

    webhooks.active = true;
    webhooks.event_types = eventTypes;
    webhooks.url = config.Webhook_Endpoint__c;
    webhooks.content_type = Constants.JSON;

    return JSON.serialize(webhooks);
  }

  /**
   * @description create and return the post HttpRequest for the webhooks
   * @author rafal.nascimento@osf.digital | 03-12-2021
   * @return HttpRequest
   **/
  public override HttpRequest getRequest() {
    String uri = DomainConstants.getCheckoutUrl(
      Enums.CheckoutRequestType.WEBHOOK
    );

    return CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_POST,
      uri,
      createBody(),
      config.Secret_Key__c
    );
  }
}
