@isTest
private class CustomExceptionTest {
  @isTest
  private static void shouldLogSingleException() {
    String moduleName = 'Unit Test';
    String customMessage = 'Data type problem';

    try {
      String text = 'non-integer-value';
      Integer.valueOf(text);
    } catch (Exception ex) {
      new CustomException()
        .module(moduleName)
        .customMessage(customMessage)
        .log(ex);
    }

    Exception_Log__c exceptionLog = [
      SELECT Id, Class_Name__c, Custom_Message__c, Module_Name__c
      FROM Exception_Log__c
      LIMIT 1
    ];

    System.assertEquals(
      customMessage,
      exceptionLog.Custom_Message__c,
      'Wrong custom message'
    );
    System.assertEquals(
      moduleName,
      exceptionLog.Module_Name__c,
      'Wrong module name'
    );
  }

  @isTest
  static void shouldLogMultipleExceptions() {
    List<String> textNumbers = new List<String>{
      '2',
      'non-integer-value',
      '001',
      '?'
    };
    List<Exception> exceptions = new List<Exception>();

    for (String textNumber : textNumbers) {
      try {
        Integer.valueOf(textNumbers);
      } catch (Exception ex) {
        exceptions.add(ex);
      }
    }

    if (!exceptions.isEmpty()) {
      new CustomException().log(exceptions);
    }

    List<Exception_Log__c> exceptionLogs = [
      SELECT Id, Class_Name__c, Custom_Message__c, Module_Name__c
      FROM Exception_Log__c
    ];

    System.assertEquals(
      exceptions.size(),
      exceptionLogs.size(),
      'Wrong exceptions quantity'
    );
  }

  @isTest
  static void shouldFailSingleException() {
    Boolean hasFailed = false;
    Exception e;
    try {
      new CustomException().log(e);
    } catch (Exception ex) {
      new CustomException().log(ex);
      hasFailed = true;
    }

    List<Exception_Log__c> exceptionLog = [
      SELECT Id, Class_Name__c, Custom_Message__c, Module_Name__c
      FROM Exception_Log__c
      LIMIT 1
    ];
    System.assertEquals(1, exceptionLog.size(), 'One exception is logged');

    System.assertEquals(
      'CustomException',
      exceptionLog[0].Module_Name__c,
      'Wrong module name'
    );
  }

  @isTest
  static void shouldFailMultipleExceptions() {
    Boolean hasFailed = false;
    Exception e;
    List<Exception> exceptions = new List<Exception>{ e };
    try {
      new CustomException().log(exceptions);
    } catch (Exception ex) {
      new CustomException().log(ex);
      hasFailed = true;
    }

    List<Exception_Log__c> exceptionLog = [
      SELECT Id, Class_Name__c, Custom_Message__c, Module_Name__c
      FROM Exception_Log__c
      LIMIT 1
    ];
    System.assertEquals(1, exceptionLog.size(), 'One exception is logged');
    System.assert(!hasFailed, 'No error should be thrown on catch');
  }
}
