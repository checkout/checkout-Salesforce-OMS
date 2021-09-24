/**
 * @description       : Wrapper class for the get/post methods for
 * @author            : rafael.nascimento@osf.digital
 * @group             :
 * @last modified on  : 03-15-2021
 * @last modified by  : rafael.nascimento@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-12-2021   rafael.nascimento@osf.digital   Initial Version
 **/
public with sharing class WebhooksWrapper {
  public String id { get; set; }

  public Boolean active { get; set; }

  public String content_type { get; set; }

  public List<String> event_types { get; set; }

  public String url { get; set; }
}
