/**
 * @description       : Prepare HttpRequest
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-09-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing abstract class BaseRequest {
  public abstract HttpRequest getRequest();
}
