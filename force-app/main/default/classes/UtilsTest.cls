@isTest
private class UtilsTest {
  @isTest
  private static void validateFieldSecurityTest() {
    System.runAs(getReadOnlyUser()) {
      System.assertEquals(
        false,
        Utils.validateFieldSecurity(
          Checkout_Payment_Config__c.class.getName(),
          new List<String>{ 'Secret_Key__c' },
          Constants.IS_CREATEABLE
        ),
        'The user is readonly'
      );

      System.assertEquals(
        false,
        Utils.validateFieldSecurity(
          Checkout_Payment_Config__c.class.getName(),
          new List<String>{ 'Secret_Key__c' },
          Constants.IS_UPDATEABLE
        ),
        'The user is readonly'
      );
    }
  }

  @isTest
  private static void validateObjectSecurityTest() {
    System.runAs(getReadOnlyUser()) {
      System.assertEquals(
        false,
        Utils.validateObjectSecurity(
          Checkout_Payment_Config__c.class.getName(),
          Constants.IS_CREATEABLE
        ),
        'The user is readonly'
      );

      System.assertEquals(
        false,
        Utils.validateObjectSecurity(
          Checkout_Payment_Config__c.class.getName(),
          Constants.IS_UPDATEABLE
        ),
        'The user is readonly'
      );

      System.assertEquals(
        false,
        Utils.validateObjectSecurity(
          Checkout_Payment_Config__c.class.getName(),
          Constants.IS_ACCESSIBLE
        ),
        'The user is readonly'
      );
    }
  }

  private static User getReadOnlyUser() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Read Only'];

    User userA = new User();
    userA.Username = 'test@uniqueT45.com';
    userA.LastName = 'test';
    userA.Email = 'test@a.com';
    userA.Alias = 'test';
    userA.TimeZoneSidKey = 'America/Los_Angeles';
    userA.LocaleSidKey = 'en_US';
    userA.EmailEncodingKey = 'UTF-8';
    userA.ProfileId = p.Id;
    userA.LanguageLocaleKey = 'en_US';
    insert userA;

    return userA;
  }
}
