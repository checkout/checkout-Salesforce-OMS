@isTest
private class WebhooksfallbackBatch_ScheduableTest {
  @isTest
  private static void scheduleTest() {
    Test.startTest();
    WebhooksfallbackBatch_Scheduable scheduable = new WebhooksfallbackBatch_Scheduable();
    system.schedule('PaymentStatusScheduable', '0 5 * * * ?', scheduable);
    Test.stopTest();

    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM CronTrigger
        WHERE CronJobDetail.Name = 'PaymentStatusScheduable'
      ],
      'Jobs should not fail'
    );
  }
}
