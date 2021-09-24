/**
 * @description       : Create the Http Request
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-09-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class Constants {
  public static final String NOTIFICATION_TYPE_PAYMENT = 'payment';
  public static final String GATEWAY_REF_NUMBER_MISSING = 'GatewayRefNumber is missing';
  public static final String PAYMENT_AUTHORIZATION_ID_MISSING = 'Missing payment authorization id';
  public static final String PAYMENT_ID_MISSING = 'Missing payment id!';
  public static final String PAYMENT_AUTHORIZATION_NOT_FOUND = 'Payment Authorization not found';
  public static final String REQUEST_PROCESSED = 'The request should be processed successfully.';
  public static final String REQUIRED_FIELD_MISSING_AMOUNT = 'Required Field Missing : Amount';
  public static final String PAYMENT_NOT_FOUND = 'Payment not found';
  public static final String RESULT_NULL_FOR_ADAPTER = 'result is null for adapter notification!';
  public static final String SALESFORCE_VALIDATION_EXPECTED = 'SalesforceValidationException expected';
  public static final String ORDER_PAYMENT_SUMMARY_ID_MISSING = 'Order payment summary is missing';
  public static final String ORDER_SUMMARY_NOT_FOUND = 'Order summary not found;';
  public static final String ORDER_ITEMS_NOT_FOUND = 'There are not items founded in this order';
  public static final String CONFIG_ALREADY_ACTIVE = 'There is another payment configuration already active, please disable it before activating a new one.';
  public static final String PRODUCTION_ENVIRONMENT = 'Production';
  public static final String KLARNA_EXTERNAL = 'klarna-external';
  public static final String KLARNA = 'klarna';

  public static final String IS_CREATEABLE = 'isCreateable';
  public static final String IS_UPDATEABLE = 'isUpdateable';
  public static final String IS_ACCESSIBLE = 'isAccessible';

  public static final String CONTENT_TYPE = 'Content-Type';
  public static final String APPLICATION_JSON = 'application/json';
  public static final String JSON = 'json';
  public static final String AUTHORIZATION = 'Authorization';
  public static final String CKO_SIGNATURE = 'CKO-Signature';
  public static final String HMAC_SHA256 = 'HmacSHA256';
  public static final String WEBHOOK_TEST_SECRET_KEY = 'dummyValue';

  public static final String HTTP_METHOD_POST = 'POST';
  public static final String HTTP_METHOD_GET = 'GET';
  public static final String HTTP_METHOD_PUT = 'PUT';
  public static final String HTTP_METHOD_PATCH = 'PATCH';

  public static final String INVALID_AUTHORIZATION_HEADER = 'Invalid authorization header';
  public static final String INVALID_ENDPOINT = 'Invalid endpoint';
  public static final String INVALID_HTTP_METHOD = 'Invalid HTTP method';
  public static final String INVALID_BODY = 'Invalid body';
  public static final String WRONG_STATUS_CODE = 'Invalid status code';

  public static final String PROJECT_NAMESPACE = 'checkoutcom';
}
