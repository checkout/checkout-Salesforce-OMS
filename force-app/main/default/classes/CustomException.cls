/**
 * @description Class for logging exceptions to org
 */
public with sharing class CustomException extends Exception {
  String moduleName { get; set; }
  String stackTrace { get; set; }
  String className { get; set; }
  String methodName { get; set; }
  String customMessage { get; set; }

  /**
   * @description Logs the given exception by creating Exception_Log__c record
   * @param ex Exception to be logged
   **/
  public void log(Exception ex) {
    insertObject(ex);
  }

  /**
   * @description Logs the given exceptions by creating Exception_Log__c records
   * @param exceptions List of exceptions to be logged
   **/
  public void log(List<Exception> exceptions) {
    insertObject(exceptions);
  }

  /**
   * @description Sets module name for the current instance
   * @param name Name of the module where the exception occurs
   * @return CustomException instance to use fluently
   **/
  public CustomException module(String name) {
    moduleName = name;
    return this;
  }

  /**
   * @description Sets custom message for the current instance
   * @param message Custom message related to the exception
   * @return CustomException instance to use fluently
   **/
  public CustomException customMessage(String message) {
    customMessage = message;
    return this;
  }

  /**
   * @description Parses the exception to retrieve stack trace, class and method names where the exception occurs
   * @param ex Exception to be parsed
   **/
  private void parseExceptionData(Exception ex) {
    try {
      stackTrace = ex.getStackTraceString().substringBefore('\n');

      String namespaceValue = Constants.PROJECT_NAMESPACE + '.';
      className = stackTrace.contains(namespaceValue)
        ? namespaceValue +
          stackTrace.substringAfter(namespaceValue).substringBefore('.')
        : stackTrace.substringAfter('.').substringBefore('.');

      methodName = stackTrace.substringBefore(':')
        .substringAfter(className)
        .substringAfter('.');
    } catch (Exception e) {
      new CustomException().Module('CustomException').log(e);
    }
  }

  /**
   * @description Inserts the exception as Exception_Log__c object
   * @param ex Exception to be inserted
   **/
  private void insertObject(Exception ex) {
    try {
      parseExceptionData(ex);

      Exception_Log__c log = getExceptionLog(ex);

      if (
        log != null &&
        Utils.validateObjectSecurity(
          Exception_Log__c.class.getName(),
          Constants.IS_CREATEABLE
        )
      ) {
        insert log;
      }
    } catch (Exception e) {
      new CustomException().Module('CustomException').log(e);
    }
  }

  /**
   * @description Inserts the exceptions as Exception_Log__c objects
   * @param exceptions List of exception to be inserted
   **/
  private void insertObject(List<Exception> exceptions) {
    try {
      List<Exception_Log__c> exceptionLogs = new List<Exception_Log__c>();

      for (Exception ex : exceptions) {
        parseExceptionData(ex);

        Exception_Log__c log = getExceptionLog(ex);
        if (log != null) {
          exceptionLogs.add(log);
        }
      }

      if (
        !exceptionLogs.isEmpty() &&
        Utils.validateObjectSecurity(
          Exception_Log__c.class.getName(),
          Constants.IS_CREATEABLE
        )
      ) {
        insert exceptionLogs;
      }
    } catch (Exception e) {
      new CustomException().Module('CustomException').log(e);
    }
  }

  /**
   * @description Creates Exception_Log__c instance and assigns the exception information
   * @param ex Exception object to be convereted to Exception_Log__c
   * @return Exception_Log__c sObject instance
   **/
  private Exception_Log__c getExceptionLog(Exception ex) {
    Exception_Log__c log;

    if (
      Utils.validateFieldSecurity(
        Exception_Log__c.class.getName(),
        new List<String>{
          'Module_Name__c',
          'Class_Name__c',
          'Method_Name__c',
          'Custom_Message__c',
          'Exception_Message__c',
          'Stack_Trace__c',
          'Line_Number__c',
          'Exception_Type__c',
          'Exception_Cause__c'
        },
        Constants.IS_CREATEABLE
      )
    ) {
      log = new Exception_Log__c();
      log.Module_Name__c = moduleName;
      log.Class_Name__c = className;
      log.Method_Name__c = methodName;
      log.Custom_Message__c = customMessage;
      log.Exception_Message__c = ex.getMessage();
      log.Stack_Trace__c = ex.getStackTraceString();
      log.Line_Number__c = ex.getLineNumber();
      log.Exception_Type__c = ex.getTypeName();
      log.Exception_Cause__c = String.valueOf(ex.getCause());
    }

    return log;
  }
}
