trigger CheckoutPaymentConfigTrigger on Checkout_Payment_Config__c(
  before insert,
  before update
) {
  CheckoutPaymentConfigTriggerHandle handler = new CheckoutPaymentConfigTriggerHandle();

  if (Trigger.isBefore) {
    if (Trigger.isUpdate) {
      handler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }

    if (Trigger.isInsert) {
      handler.handleBeforeCreate(Trigger.new);
    }
  }
}
