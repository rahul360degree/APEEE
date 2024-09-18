@isTest
public class SubscriptionCloneBatchTest {
    @testsetup
    static void testsetup(){
        SchoolYear__c schYr = new SchoolYear__c();
        schYr.Name = '2022-2023';
        schYr.IsActive__c = true;
        schYr.Startdate_trimester_1__c = System.today();
        insert schYr;
        SchoolYear__c schYr1 = new SchoolYear__c();
        schYr1.Startdate_trimester_1__c = System.today() ;
        schYr1.Name = '2023-2024';
        schYr1.IsActive__c = true;
        insert schYr1;
        School__c sch = new School__c();
        sch.Name = 'test';
        insert sch;
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
      
        Class__c c = new Class__c();
        c.Name = 'P4FCR';
        c.Class__c = 'C';
        c.Schoolyear__c = schYr.Id;
        c.School__c = sch.Id;
        insert c;
        ClassType__c ct = new ClassType__c();
        ct.Name = 'P4FR';
        ct.Level__c = 'P4';
        ct.School__c = sch.Id;
        insert ct;
        ClassEnrollment__c ce = new ClassEnrollment__c();
        ce.Contact__c = con.Id;
        ce.School_Year__c = schYr.Id;
        ce.Class__c = c.Id;
        ce.Class_Type__c = ct.Id;
        ce.Status__c = 'Enrolled';
        insert ce;
       
        CanteenSubscription__c cs = new CanteenSubscription__c();
        cs.Enrollment__c = ce.Id;
        cs.Student__c = con.Id;
        cs.Class__c = ce.Class__r.Class__c;
        cs.Class_Type__c = ce.Class_Type__r.level__c;
        cs.Status__c = 'Approved';
        cs.SchoolYear__c = schYr.Id;
        cs.Monday__c = true;
        cs.Tuesday__c = true;
        cs.Wednesday__c = true;
        insert cs;
        ClassEnrollment__c ce1 = new ClassEnrollment__c();
        ce1.Contact__c = con.Id;
        ce1.School_Year__c = schYr1.Id;
        ce1.Class__c = c.Id;
        ce1.Class_Type__c = ct.Id;
        ce1.status__c = 'Enrolled';
        insert ce1;
        BusSubscription__c bs = new BusSubscription__c();
        bs.SchoolYear__c = schYr.Id;
        bs.School__c = sch.Id;
        bs.Student__c = con.Id;
        bs.Level__c= 'M1';
        insert bs;
        
        BusStop__c bst = new BusStop__c();
       // bst.Name = 'test';
        bst.Active__C = true;
        insert bst;
        Route__c rt = new Route__c();
        rt.name = 'test';
        insert rt;
        
        busride__c bsride = new busride__c();
        bsride.Subscription__c = bs.id;
        bsride.Status__c = 'Approved';
        bsride.Route__c = rt.Id ;
        bsride.Busstop__c = bst.id; 
        bsride.Ridetype__c ='Weekly';
        bsride.Startdate__c = System.today();
        insert bsride;
        
    }
    @isTest 
    static void batchTest(){
        List<SchoolYear__c> schYrList = [Select Id from SchoolYear__c ];
        Test.startTest();
        SubscriptionCloneBatch batch = new SubscriptionCloneBatch(schYrList[0].Id,schYrList[1].Id,'Bus Subscription','2023-2024','','');
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    
     @isTest 
    static void batchTest2(){
        List<SchoolYear__c> schYrList = [Select Id from SchoolYear__c ];
        schYrList[1].isActive__c = true;
        update schYrList;
        Test.startTest();
        SubscriptionCloneBatch batch = new SubscriptionCloneBatch(schYrList[0].Id,schYrList[1].Id,'Bus Subscription','2023-2024','','');
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    
     @isTest 
    static void batchCanteenSubTest3(){
        List<SchoolYear__c> schYrList = [Select Id from SchoolYear__c ];
        schYrList[1].isActive__c = true;
        update schYrList;
        Test.startTest();
        SubscriptionCloneBatch batch = new SubscriptionCloneBatch(schYrList[0].Id,schYrList[1].Id,'Canteen Subscription','2023-2024','','');
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
    
   
}