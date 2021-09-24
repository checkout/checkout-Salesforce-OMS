/**
 * @description       : Escheduable class, that calls update of the statu`s payments
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-29-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-29-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhooksfallbackBatch_Scheduable implements Schedulable {
  public void execute(SchedulableContext sc) {
    Webhooksfallback_batch batch = new Webhooksfallback_batch();
    Database.executeBatch(batch, 100);
  }
}
