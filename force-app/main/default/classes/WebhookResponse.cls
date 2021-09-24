/**
 * @description       : Wrapper class for the webhook event response
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-22-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhookResponse {
  public Enums.WebhookRequestType type { get; set; }
  public Data data { get; set; }

  public with sharing class Data {
    @testVisible
    private Double amount { private get; set; }
    public String id { get; set; }

    public Double getAmount() {
      return this.amount / 100;
    }
  }
}
