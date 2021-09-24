/**
 * @description       : Declare Enums
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class Enums {
  public enum PaymentType {
    CAPTURE
  }
  public enum ProcessingMode {
    EXTERNAL
  }
  public enum PaymentStatus {
    PROCESSED,
    PENDING,
    DRAFT,
    CAPTURED
  }
  public enum CheckoutRequestType {
    CAPTURE,
    REFUND,
    PAYMENT,
    GET_DETAILS,
    GET_DETAILS_WEBHOOK,
    WEBHOOK,
    KLARNA_CAPTURE
  }
  public enum WebhookRequestType {
    PAYMENT_CAPTURED,
    PAYMENT_CAPTURE_DECLINED,
    PAYMENT_REFUNDED,
    PAYMENT_REFUND_DECLINED
  }
  public enum PaymentDetailStatus {
    CAPTURED,
    PARTIALLY_CAPTURED,
    REFUNDED,
    PARTIALLY_REFUNDED
  }
  public enum PaymentMethod {
    VISA,
    KLARNA
  }
}
