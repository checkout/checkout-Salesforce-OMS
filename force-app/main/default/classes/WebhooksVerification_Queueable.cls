/**
 * @description       : Make the subscription of the webhooks at Chekout Api
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-24-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhooksVerification_Queueable implements Queueable, Database.AllowsCallouts {
  private List<Checkout_Payment_Config__c> configs;

  public WebhooksVerification_Queueable(
    List<Checkout_Payment_Config__c> configs
  ) {
    this.configs = configs;
  }

  public void execute(QueueableContext context) {
    List<Webhook_Event_Types__mdt> eventTypes = Utils.validateFieldSecurity(
        Webhook_Event_Types__mdt.class.getName(),
        new List<String>{ 'Checkout_Name__c' },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT Checkout_Name__c
          FROM Webhook_Event_Types__mdt
          WHERE Subscribed__c = TRUE
        ]
      : null;

    List<SalesforceValidationException> exceptions = new List<SalesforceValidationException>();

    for (Checkout_Payment_Config__c config : configs) {
      SalesforceValidationException ex = upsertWebHooks(eventTypes, config);
      if (ex != null) {
        exceptions.add(ex);
      }
    }

    if (!exceptions.isEmpty()) {
      new CustomException().log(exceptions);
    }
  }

  /**
   * @description get the event types active on the webhooks at checkout api
   * @author rafael.nascimento@osf.digital | 03-12-2021
   * @param config the active Checkout_Payment_Config__c
   * @return A set of the event types name
   **/

  private WebhooksWrapper getOnlineWebhook(Checkout_Payment_Config__c config) {
    HttpRequest request = new WebhooksGetRequest(config.Secret_Key__c)
      .getRequest();
    HttpResponse response = new http().send(request);

    if (response.getStatusCode() == 200) {
      for (
        WebhooksWrapper webhooks : ((List<WebhooksWrapper>) JSON.deserialize(
          response.getBody(),
          List<WebhooksWrapper>.class
        ))
      ) {
        if (webhooks.url == config.Webhook_Endpoint__c) {
          return webhooks;
        }
      }
    }

    return null;
  }

  /**
   * @description update or insert the active event types
   * @author rafael.nascimento@osf.digital | 03-12-2021
   * @param eventTypes list of the active event types at the org
   * @param config the active Checkout_Payment_Config__c
   * @return A set of the event types name
   **/
  private SalesforceValidationException upsertWebHooks(
    List<Webhook_Event_Types__mdt> eventTypes,
    Checkout_Payment_Config__c config
  ) {
    List<String> eventsToPost = new List<String>();
    WebhooksWrapper webhook = getOnlineWebhook(config);
    HttpRequest request;

    for (Webhook_Event_Types__mdt eventType : eventTypes) {
      eventsToPost.add(eventType.Checkout_Name__c);
    }

    if (webhook != null) {
      webhook.event_types = eventsToPost;
      request = new WebhooksPatchRequest(webhook, config).getRequest();
    } else {
      request = new WebhooksPostRequest(eventsToPost, config).getRequest();
    }

    HttpResponse response = new http().send(request);

    if (response.getStatusCode() < 200 || response.getStatusCode() > 299) {
      return new SalesforceValidationException(
        'Request not successful: StatusCode: ' +
        response.getStatusCode() +
        ' Status:' +
        +response.getStatus()
      );
    }

    return null;
  }
}
