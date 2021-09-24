/**
 * @description       : Create the Http Request
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-22-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class CalloutUtility {
  /**
   * @description create and return a HttpRequest
   * @author roberto.ehlert@osf.digital | 07-14-2020
   * @param verb can be PUT,POST,DELETE,GET
   * @param apiMethod uri
   * @param bodyContent content body
   * @param secretKey key provided by checkout
   * @return HttpRequest
   **/
  public static HttpRequest createHttpRequest(
    String verb,
    String apiMethod,
    String bodyContent,
    String secretKey
  ) {
    HttpRequest req = new HttpRequest();

    req.setHeader(Constants.CONTENT_TYPE, Constants.APPLICATION_JSON);

    if (String.isNotBlank(secretKey)) {
      req.setHeader(Constants.AUTHORIZATION, secretKey);
    }

    req.setEndpoint(apiMethod);

    if (String.isNotBlank(bodyContent)) {
      req.setBody(bodyContent);
    }

    req.setMethod(verb);

    return req;
  }
}
