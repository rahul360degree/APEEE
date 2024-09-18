@isTest
public class OccasionalSupervisionControllerTest {
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
        con.User__c = UserInfo.getUserId();
        insert con;
        
        School__c sc = new School__c();
        sc.Name = 'Woluwe';
        insert sc;
        
        SchoolYear__c sy = new SchoolYear__c();
        sy.Name = '2023-2024';
        sy.Startdate_trimester_1__c = system.today();
        sy.IsActive__c = true;
        insert sy;
        
        ClassType__c ct = new ClassType__c();
        ct.Name = 'S6FR';
        ct.School__c = sc.Id;
        insert ct;

        Class__c cls = new Class__c();
        cls.Name = 'S6FRD';
        cls.Schoolyear__c = sy.Id;
        cls.School__c = sc.Id;
        cls.Class_Type__c = ct.Id;
        insert cls;
        
        ClassEnrollment__c ce = new ClassEnrollment__c();
        ce.Contact__c = con.id;
        ce.School_Year__c = sy.Id;
        ce.Class_Type__c = ct.Id;
        ce.Class__c = cls.Id;
        insert ce;
        
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
        
        OccasionalSupervision__c os = new OccasionalSupervision__c();
        os.Name = 'test';
        os.StatusofApproval__c = 'Booked';
        insert os;
    } 
    @isTest
    public static void getHouseholdStudentTest(){
        TestClassHelper.isThrowException = true;
        List<Contact> conList = [SELECT id,Name FROM Contact];
        String str = UserInfo.getUserId();
        OccasionalSupervisionController.getHouseholdStudent(str);
    }
    @isTest
    public static void getPlannedActivityTest(){
        TestClassHelper.isThrowException = true;
        List<AccountContactRelation> acrList = [SELECT id,AccountId,ContactId,Mobile__c,Relation__c FROM AccountContactRelation];
        List<ClassEnrollment__c> ceList = [SELECT Id,Contact__c,School__c,Class_txt__c,Class__c,School_year_txt__c FROM ClassEnrollment__c];
        List<Planned_Activity__c> paList = [SELECT id,Name,Code__c,Day__c,School_Year_Txt__c,End_Date__c,End_Time__c,School_Year__c,School__c,Start_Date__c,Start_Time__c,School_txt__c,Activity_Name_EN__c,Class__c FROM Planned_Activity__c WHERE Activity_Name_EN__c =: 'Occassional Supervision'];
        OccasionalSupervisionController.getPlannedActivity(acrList[0].id);
    }
    @isTest
    public static void occSupervisionSubmit(){
        TestClassHelper.isThrowException = true;
        List<Contact> conList = [SELECT id,Name FROM Contact];
        List<Planned_Activity__c> paList = [SELECT id,Name,Code__c FROM Planned_Activity__c];
        List<Class__c> cList = [SELECT id,name from Class__c];
        List<SchoolYear__c> scholYear = [SELECT id,name from SchoolYear__c];
        
        String str = UserInfo.getUserId();
        string occName = 'test';
        date occDate = system.today(); 
        string occPlannedActivity = 'test';
        string occClass = 'S6FR';
        date startDate = system.today();
        date endDate = system.today();
        string activityName = 'Occasional Supervision'; 
        string dayofWeek = 'Monday';
        string conId = conList[0].id;
        string parentId = 'dfnier';
        OccasionalSupervisionController.occSupervisionSubmit(occName,occDate,paList[0].id,cList[0].id,scholYear[0].id,startDate,endDate,null,null,activityName,dayofWeek,conList[0].id,null);
    }
}