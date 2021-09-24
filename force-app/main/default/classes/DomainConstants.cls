/**
 * @description       : Get the Checkout URL based on Request Types
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   roberto.ehlert@osf.digital   Initial Version
 **/
public with sharing class DomainConstants {
  static final String BASE_URL = '/payments/{0}';
  static final String CAPTURE = '/captures';
  static final String REFUND = '/refunds';
  static final String KLARNA_BASE_URL = '/klarna-external/orders/{0}';

  /**
   * @description Gets the Checkout URL based for the specified @param requestType
   * @author roberto.ehlert@osf.digital | 09-03-2021
   * @param requestType
   * @return Checkout URL
   **/
  public static String getCheckoutUrl(Enums.CheckoutRequestType requestType) {
    switch on requestType {
      when CAPTURE {
        return String.format('{0}{1}', new List<String>{ BASE_URL, CAPTURE });
      }
      when REFUND {
        return String.format('{0}{1}', new List<String>{ BASE_URL, REFUND });
      }
      when GET_DETAILS {
        return String.format('{0}', new List<String>{ BASE_URL });
      }
      when GET_DETAILS_WEBHOOK {
        return String.format(
          'callout:Checkout_Payment{0}',
          new List<String>{ BASE_URL }
        );
      }
      when WEBHOOK {
        return 'callout:Checkout_Payment/webhooks';
      }
      when KLARNA_CAPTURE {
        return String.format(
          '{0}{1}',
          new List<String>{ KLARNA_BASE_URL, CAPTURE }
        );
      }
      when else {
        return '';
      }
    }
  }
}
