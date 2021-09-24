/**
 * @description       : handle for the webhook notification/events
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-22-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   03-22-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class CheckoutNotificationHandler {
  /**
   * @description get the notification response after the notification is processed in the Checkout Adapter
   * @author rafael.nascimento@osf.digital | 03-22-2021
   * @param reponseData contains the webhook notification received in the HTTP POST request
   * @return HttpResponse notification response after the notification is processed by the Checkout Adapter
   **/
  public static HttpResponse getNotificationResponseFromAdapter(
    WebhookResponse reponseData
  ) {
    String bodyContent = JSON.serialize(reponseData);
    String uri = 'callout:Checkout_Notification';
    HttpRequest req = CalloutUtility.createHttpRequest(
      Constants.HTTP_METHOD_POST,
      uri,
      bodyContent,
      null
    );

    return new Http().send(req);
  }
}
