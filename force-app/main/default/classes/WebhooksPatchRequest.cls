/**
 * @description       : Create the patch request of webhook endpoint
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 05-28-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   05-28-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhooksPatchRequest extends BaseRequest {
    private Checkout_Payment_Config__c config;
    WebhooksWrapper webhook;
  
    public WebhooksPatchRequest(
      WebhooksWrapper webhook,
      Checkout_Payment_Config__c config
    ) {
      this.webhook = webhook;
      this.config = config;
    }

    /**
     * @description create and return the patch HttpRequest for the webhooks
     * @author rafal.nascimento@osf.digital | 05-28-2021
     * @return HttpRequest
     **/
    public override HttpRequest getRequest() {
      String uri = DomainConstants.getCheckoutUrl(
        Enums.CheckoutRequestType.WEBHOOK
      );
  
      return CalloutUtility.createHttpRequest(
        Constants.HTTP_METHOD_PATCH,
        uri+'/'+webhook.id,
        JSON.serialize(webhook),
        config.Secret_Key__c
      );
    }
  }
  