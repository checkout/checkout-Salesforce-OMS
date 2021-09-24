/**
 * @description       : queries for Checkout Payment Config
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-22-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-10-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class CheckoutPaymentConfigQuery {
  /**
   * @description Get secret key for the correponding active Checkout Payment Config
   * @author roberto.ehlert@osf.digital | 09-03-2021
   * @return String secret key
   **/
  public static String getSecretKey() {
    List<Checkout_Payment_Config__c> activeConfigs = Utils.validateFieldSecurity(
        Checkout_Payment_Config__c.class.getName(),
        new List<String>{ 'Secret_Key__c' },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT Secret_Key__c
          FROM Checkout_Payment_Config__c
          WHERE Active__c = TRUE
          LIMIT 1
        ]
      : null;

    return !activeConfigs.isEmpty() ? activeConfigs[0].Secret_Key__c : null;
  }

  /**
   * @description Get Klarna Settings
   * @author ana-maria.levinta@osf.digital | 05-20-2021
   * @return Klarna_Setting__mdt the settings for the Klarna payment
   **/
  public static Klarna_Setting__mdt getKlarnaSettings() {
    return Utils.validateFieldSecurity(
        Klarna_Setting__mdt.class.getName(),
        new List<String>{
          'Description_Details__c',
          'Environment__c',
          'Include_Description__c',
          'Include_Products__c',
          'Include_Shipping_Delay__c',
          'Include_Shipping_Info__c',
          'Shipping_Delay_Value__c'
        },
        Constants.IS_ACCESSIBLE
      )
      ? [
          SELECT
            Description_Details__c,
            Environment__c,
            Include_Description__c,
            Include_Products__c,
            Include_Shipping_Delay__c,
            Include_Shipping_Info__c,
            Shipping_Delay_Value__c
          FROM Klarna_Setting__mdt
          WHERE Label = 'Default'
          LIMIT 1
        ]
      : null;
  }
}
