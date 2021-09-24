/**
 * @description       : Roberto Ehlert
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 05-17-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-12-2021   roberto.ehlert@osf.digital   Initial Version
 * 1.1   05-17-2021   roberto.ehlert@osf.digital   Restrict amount original access.
 **/

public with sharing class PaymentDetails {
  public String id;
  public String reference;
  public Boolean approved;
  public String status;
  public Source source;

  private Double amount;

  public with sharing class Source {
    public String type;
  }

  /**
   * Checkout API sends the response with the amount without commas.
   * Needs to be splitted by 100 to get the correct amount.
   * @author roberto.ehlert@osf.digital | 03-12-2021
   * @return Payment
   **/
  public Double getAmount() {
    return this.amount / 100;
  }
}
