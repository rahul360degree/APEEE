@istest
public class ActivityBookingGPSSchedulerTest {
    public static testMethod void testschedule() {
        Test.StartTest();
        ActivityBookingGPSScheduler testsche = new ActivityBookingGPSScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}