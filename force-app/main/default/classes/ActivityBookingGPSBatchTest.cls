@isTest
public class ActivityBookingGPSBatchTest {
    static testMethod void bacthTest(){
        Id householdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingStreet = '123 Main St';
        acc.BillingCity = 'Sample City';
        acc.BillingState = 'CA';
        acc.BillingPostalCode = '12345';
        acc.BillingCountry = 'USA';
        acc.RecordTypeId = householdAccount;
        insert acc;
        
        School__c sc = new School__c();
        sc.Name = 'Woluwe';
        insert sc;
        
        Activity__c activity = new Activity__c();
        activity.Active__c =  true;
        activity.Activity_name_EN__c = 'test ACtivity';
        activity.Activity_Name_FR__c = 'Surveillance avec activité';
        activity.Activity_Type__c = 'sport';
        activity.School__c = sc.Id;
        insert activity;
        
        Time startTime = Time.newInstance(12,5,2,7);
        Time endTime = Time.newInstance(12,5,2,7);
        
        Planned_Activity__c pa = new Planned_Activity__c();
        pa.Activity__c = activity.Id;
        pa.Code__c = '1234';
        pa.Start_Date__c = system.today();
        pa.End_Date__c = system.today()+1;
        pa.Day__c = 'Monday';
        pa.Maximum_number__c = 12;
        pa.Class__c = 'p1';
        pa.Start_Time__c = startTime;
        pa.End_Time__c = endTime;
        insert pa;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test con';
        con.User__c = UserInfo.getUserId();
        insert con;
        
        Activity_Booking__c ab = new Activity_Booking__c();
        ab.PlannedActivity__c = pa.Id;
        ab.Student__c = con.Id;
        ab.Parent__c = con.Id;
        ab.Status__c = 'Booked';
        insert ab;
        Test.startTest();
        ActivityBookingGPSBatch ba= new ActivityBookingGPSBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
        Activity_Booking__c abObj = [select Name from Activity_Booking__c where id=:ab.Id];
    }
}