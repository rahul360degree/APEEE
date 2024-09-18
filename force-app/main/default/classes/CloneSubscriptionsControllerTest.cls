@isTest
public class CloneSubscriptionsControllerTest {
    @testsetup
    static void setupData(){
        SchoolYear__c schYr = new SchoolYear__c();
        schYr.Name = '2022-2023';
        schYr.Startdate_trimester_1__c = System.today();
        insert schYr;
        SchoolYear__c schYr1 = new SchoolYear__c();
        schYr1.Startdate_trimester_1__c = System.today() ;
        schYr1.Name = '2023-2024';
        insert schYr1;
    }
    @isTest
    static void getSchoolYearsTest(){
        Test.startTest();
        CloneSubscriptionsController.getSchoolYears();
        Test.stopTest();
    }
    
    @isTest
    static void createSubscriptionHandlerTest(){
        List<SchoolYear__c> schYrList = [Select Id from SchoolYear__c ];
        Test.startTest();
        CloneSubscriptionsController.createSubscriptionHandler(schYrList[0].Id,schYrList[1].Id,'Bus Subscription','2023-2024','','');
        Test.stopTest();
    }
}