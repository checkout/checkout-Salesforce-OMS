public with sharing class CheckoutPaymentConfigTriggerHandle {
  private void processActiveConfigs(
    List<Checkout_Payment_Config__c> configsToValidate
  ) {
    List<Checkout_Payment_Config__c> activeConfigs = new List<Checkout_Payment_Config__c>();

    for (Checkout_Payment_Config__c config : configsToValidate) {
      if (config.Active__C) {
        activeConfigs.add(config);
      }
    }

    System.enqueueJob(new WebhooksVerification_Queueable(activeConfigs));
  }

  private Boolean isValid(List<Checkout_Payment_Config__c> configs) {
    List<Checkout_Payment_Config__c> activeConfigs = new List<Checkout_Payment_Config__c>();

    for (Checkout_Payment_Config__c config : configs) {
      if (config.Active__c) {
        activeConfigs.add(config);
      }
    }

    if (!activeConfigs.isEmpty()) {
      //Only one active record should exist on database.
      List<Checkout_Payment_Config__c> activeDBConfigs = Utils.validateFieldSecurity(
          Checkout_Payment_Config__c.class.getName(),
          new List<String>{ 'Active__c', 'Name' },
          Constants.IS_ACCESSIBLE
        )
        ? [
            SELECT Id, Active__c, Name
            FROM Checkout_Payment_Config__c
            WHERE Active__c = TRUE
            LIMIT 1
          ]
        : null;

      if (!activeDBConfigs.isEmpty()) {
        //If we have one active entry in database, we can't add another active one.
        for (Checkout_Payment_Config__c config : activeConfigs) {
          config.addError(Constants.CONFIG_ALREADY_ACTIVE);
        }
        return false;
      } else {
        if (activeConfigs.size() > 1) {
          //If we have more than one record being updated/inserted as active, we add errors on all of them.
          for (Checkout_Payment_Config__c config : activeConfigs) {
            config.addError(Constants.CONFIG_ALREADY_ACTIVE);
          }
          return false;
        }
      }
    }

    return true;
  }

  public void handleBeforeCreate(List<Checkout_Payment_Config__c> newConfigs) {
    if (isValid(newConfigs)) {
      processActiveConfigs(newConfigs);
    }
  }

  public void handleBeforeUpdate(
    Map<Id, Checkout_Payment_Config__c> newMap,
    Map<Id, Checkout_Payment_Config__c> oldMap
  ) {
    if (isValid(newMap.values())) {
      processActiveConfigs(newMap.values());
    }
  }
}
