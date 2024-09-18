@IsTest
public class ActivityGateServiceTest {
    @testSetup
    static void setup(){
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
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test con';
        insert con;
        School__c sc = new School__c();
        sc.Name = 'Woluwe';
        insert sc;
        
        GateHistory__c gh = new GateHistory__c();
        gh.Account__c = acc.id;
        gh.Contact__c = con.Id;
        gh.Mobile__c = '9988776655';
        gh.Relation__c = 'Father';
        insert gh;
        
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
        
        Activity_Monitor__c am = new Activity_Monitor__c();
        am.Planned_Activity__c = pa.Id;
        insert am;
        
        Activity_Booking__c ab = new Activity_Booking__c();
        ab.PlannedActivity__c = pa.Id;
        ab.Student__c = con.Id;
        ab.Parent__c = con.Id;
        ab.Status__c = 'Booked';
        insert ab;
       
        Activity_Check__c ac = new Activity_Check__c();
        ac.Activity_Booking__c = ab.Id;
        ac.Activity_Monitor__c = am.Id;
        ac.Planned_Activity__c = pa.Id;
        ac.Check_in_Date__c = system.today();
        ac.Status__c = 'Checked Out';
        insert ac;
    }
    @isTest
    public static void getActivityCheckTest(){
        List<Activity_Check__c> acList = [SELECT id,Name,Check_in_Date__c,Status__c FROM Activity_Check__c];
        ActivityGateService.getActivityCheck();
    }
    @isTest
    public static void getContactDetailsTest(){
        List<Activity_Check__c> acList = [SELECT id,Name,Check_in_Date__c,Status__c FROM Activity_Check__c];
        ActivityGateService.getContactDetails(acList[0].id);
    }
    
    @isTest
    public static void checkOutStudentsTest(){
        List<Activity_Check__c> acList = [SELECT id,Name,Check_in_Date__c,Status__c FROM Activity_Check__c];
        List<AccountContactRelation> acrList = [SELECT id,AccountId,ContactId,Mobile__c,Relation__c FROM AccountContactRelation];
        ActivityGateService.checkOutStudents(acrList,acList[0].id);
    }
    @isTest
    public static void sendNotificationToMonitorsTest(){
        List<Activity_Monitor__c> acList = [SELECT id,Name FROM Activity_Monitor__c];
        ActivityGateService.sendNotificationToMonitors(acList[0].Name);
    }
}