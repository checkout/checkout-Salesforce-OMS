/**
 * @description       : Prepare HttpRequest for Capture payment Checkout
 * @author            : roberto.ehlert@osf.digital
 * @group             :
 * @last modified on  : 03-09-2021
 * @last modified by  : roberto.ehlert@osf.digital
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-09-2021   roberto.ehlert@osf.digital   Initial Version
 **/

public with sharing class Utils {
  /**
   * @description Validates field level security
   * @param obj Object to validate
   * @param fieldsToCheck List of fields to validate
   * @param actionToCheck Action to validate (isCreatable | isUpdatable | isAccessible)
   * @return True if the current user has permission to perform the action for the specified fields of the object
   **/
  public static Boolean validateFieldSecurity(
    String obj,
    List<String> fieldsToCheck,
    String actionToCheck
  ) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType leadSchema = schemaMap.get(obj);
    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe()
      .fields.getMap();

    if (!validateObjectSecurity(obj, actionToCheck)) {
      return false;
    }

    for (String fieldName : fieldMap.keySet()) {
      Schema.DescribeFieldResult describeField = fieldMap.get(fieldName)
        .getDescribe();
      if (fieldsToCheck.contains(describeField.getLocalName())) {
        if (
          actionToCheck.equals(Constants.IS_CREATEABLE) &&
          !describeField.isCreateable()
        ) {
          return false;
        } else if (
          actionToCheck.equals(Constants.IS_UPDATEABLE) &&
          !describeField.isUpdateable()
        ) {
          return false;
        } else if (
          actionToCheck.equals(Constants.IS_ACCESSIBLE) &&
          !describeField.isAccessible()
        ) {
          return false;
        }
      }
    }

    return true;
  }

  /**
   * @description Validates object level security
   * @param obj Object to validate
   * @param actionToCheck Action to validate
   * @return True if the current user has permission to perform the action for the specified object
   **/
  public static Boolean validateObjectSecurity(
    String obj,
    String actionToCheck
  ) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType leadSchema = schemaMap.get(obj);
    Schema.DescribeSObjectResult result = leadSchema.getDescribe();

    if (
      actionToCheck.equals(Constants.IS_CREATEABLE) && !result.isCreateable()
    ) {
      return false;
    } else if (
      actionToCheck.equals(Constants.IS_UPDATEABLE) && !result.isUpdateable()
    ) {
      return false;
    } else if (
      actionToCheck.equals(Constants.IS_ACCESSIBLE) && !result.isAccessible()
    ) {
      return false;
    }
    return true;
  }
}
