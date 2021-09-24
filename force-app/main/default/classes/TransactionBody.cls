/**
 * @description       : Class to build the body for transaction classes.
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 18-05-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0  18-05-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class TransactionBody {
  public static TransactionBody transactionBody;

  public with sharing class Root {
    private Integer amount { get; private set; }
    public String reference { get; set; }

    public void setAmount(Double amount) {
      this.amount = Integer.valueOf(amount * 100);
    }
  }

  public static TransactionBody getInstance() {
    if (transactionBody == null) {
      transactionBody = new TransactionBody();
    }

    return transactionBody;
  }

  @SuppressWarnings('PMD.EmptyStatementBlock')
  private TransactionBody() {
    //The instance its build internally.
  }

  public String getBody(Double amount, String reference) {
    TransactionBody.Root root = new TransactionBody.Root();
    root.setAmount(amount);
    root.reference = reference;

    return JSON.serialize(root);
  }
}
