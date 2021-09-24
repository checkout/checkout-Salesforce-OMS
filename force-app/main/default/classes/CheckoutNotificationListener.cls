/**
 * @description       : listener for the webhook notifications
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-22-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-10-2021   rafael.nascimento@osf.digital   Initial Version
 **/
@RestResource(urlMapping='/Checkout_Notifications')
global with sharing class CheckoutNotificationListener {
  @HttpPost
  global static void handlePost() {
    try {
      RestRequest request = RestContext.request;
      WebhookResponse webhookNotification = null;

      if (isValidWebhook(request)) {
        if (String.isNotBlank(request.requestBody.toString())) {
          webhookNotification = (WebhookResponse) JSON.deserialize(
            request.requestBody.toString().trim(),
            WebhookResponse.class
          );
        }

        if (webhookNotification != null) {
          RestResponse restRes = RestContext.response;
          HttpResponse adapterResponse = CheckoutNotificationHandler.getNotificationResponseFromAdapter(
            webhookNotification
          );

          if (adapterResponse != null) {
            restRes.responseBody = adapterResponse.getBodyAsBlob();
            restRes.statusCode = adapterResponse.getStatusCode();
          } else {
            restRes.responseBody = blob.valueOf(
              Constants.RESULT_NULL_FOR_ADAPTER
            );
            restRes.statusCode = 500;
          }
        }
      }
    } catch (Exception e) {
      new CustomException().log(e);
      RestResponse res = RestContext.response;
      res.responseBody = blob.valueOf(e.getMessage());
      res.statusCode = 500; //internal server error
    }
  }

  /** 
    * @description Takes webhook's body and apply the SHA-256 hash function to it, using the secret key as the hash key. 
    Then compare the resulting HMAC to the one contained in the CKO-Signature header. 
    If the HMACs are identical, then the data corresponds to what Checkout.com sent.
    * @param request the HTTP request to be validated
    * @return true if the validation passes, false otherwise
  */
  private static Boolean isValidWebhook(RestRequest request) {
    if (request != null && request.requestBody != null) {
      String secretKey = CheckoutPaymentConfigQuery.getSecretKey();
      if (Test.isRunningTest()) {
        secretKey = Constants.WEBHOOK_TEST_SECRET_KEY;
      }
      String headerHMAC = request.headers.get(Constants.CKO_SIGNATURE);

      Blob hmac = Crypto.generateMac(
        Constants.HMAC_SHA256,
        request.requestBody,
        Blob.valueOf(secretKey)
      );

      String matchWithSignature = EncodingUtil.convertToHex(hmac);

      return matchWithSignature == headerHMAC;
    }

    return false;
  }
}
