public without sharing class ActivityGateService {
    public static ResponseWrapper getActivityCheck(){
        ResponseWrapper responseWrap = new ResponseWrapper();
        List<Activity_Check__c> acList = new List<Activity_Check__c>();
        Map<String, Activity_Check__c> studentVsActivityCheckMap = new Map<String, Activity_Check__c>();

        for(Activity_Check__c ac: getActivityCheckList()) {
            if(!studentVsActivityCheckMap.containsKey(ac.Activity_Booking__r.Student__c)) {
                studentVsActivityCheckMap.put(ac.Activity_Booking__r.Student__c, ac);
            }
        }
        responseWrap.activityCheckList = studentVsActivityCheckMap.values();
        return responseWrap;
    }
    public static ResponseWrapper getContactDetails(string recordId){
        ResponseWrapper responseWrap = new ResponseWrapper();
        List<Activity_Check__c> acList = new List<Activity_Check__c>();
        acList = [SELECT  id, Activity_Booking__c FROM Activity_Check__c WHERE Id =: recordId];
        set<Id> activityBookingIds = new set<Id>();
        set<Id> studentIds = new set<Id>();
        set<Id> accIds = new set<Id>();
        for(Activity_Check__c ac : acList){
            activityBookingIds.add(ac.Activity_Booking__c);
        }
        List<Activity_Booking__c> abList = new List<Activity_Booking__c>();
        abList = [SELECT id,Student__c,Parent__c FROM Activity_Booking__c WHERE Id IN : activityBookingIds];
        for(Activity_Booking__c ab : abList){
            studentIds.add(ab.Student__c);
        }
        List<Contact> conList = new List<Contact>();
        conList = [SELECT id,AccountId FROM Contact WHERE Id In : studentIds];
        for(Contact con : conList){
            accIds.add(con.AccountId);
        }
        List<Account> accList = new List<Account>();
        accList = [SELECT id, Name FROM Account WHERE Id IN :  accIds AND RecordType.Name = 'Household'];
        for(Account ac : accList){
            accIds.add(ac.Id);
        }
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList = [SELECT id,Mobile__c, Contact_Name_Txt__c,ContactId,AccountId, Relation__c FROM AccountContactRelation WHERE AccountId IN : accIds AND Is_allowed_to_pick_up_child__c = true];
        if(!acrList.isEmpty()){
            responseWrap.AccConDetails = acrList;
        }
        return responseWrap;
    }
    public static ResponseWrapper checkOutStudents(List<AccountContactRelation> selectedRecords, string activityCheckId){
        ResponseWrapper responseWrap = new ResponseWrapper();
        System.debug('activityCheckId:::--'+activityCheckId);
        List<Activity_Check__c> acList = new List<Activity_Check__c>();
        Activity_Booking__c activityBooking = new Activity_Booking__c();
        if(activityCheckId != null){
            List<String> currentTime = new List<String>();
            Datetime cdt = System.now();
            currentTime.add(cdt.format('HH:mm a'));
            acList = [SELECT id, Name, Status__c, CheckOut__c,Student_Name__c,StudentClass__c,Activity_Booking__c FROM Activity_Check__c WHERE Id =: activityCheckId];
            acList[0].Status__c = 'Checked Out';
            acList[0].CheckOut__c = currentTime[0];
            acList[0].Check_out_date__c = system.today();
            activityBooking.Id = acList[0].Activity_Booking__c;
            activityBooking.Checked_In__c = false;
            update activityBooking;
            system.debug('acList:::'+acList);
            update acList;
        }
        GateHistory__c gh = new GateHistory__c();
        gh.Account__c = selectedRecords[0].AccountId;
        gh.Contact__c = selectedRecords[0].ContactId;
        gh.Mobile__c  = selectedRecords[0].Mobile__c;
        gh.Relation__c = selectedRecords[0].Relation__c;
        gh.StudentClass__c = acList[0].StudentClass__c;
        gh.StudentName__c = acList[0].Student_Name__c;
        insert gh;
        return responseWrap;
    }
    public static ResponseWrapper sendNotificationToMonitors(string parentName){
        ResponseWrapper responseWrap = new ResponseWrapper();

        set<Id> parentIds = new set<Id>();
        set<string> addressee = new set<string>();
        set<Id> conIds = new set<Id>();
        List<Contact> conList = new List<Contact>();
        List<Activity_Monitor__c> amList = new List<Activity_Monitor__c>();
        List<User> userList = new List<User>();

        Integer currentYear = Date.today().year();
        String currentYearString = currentYear + '-' + (currentYear + 1);

        amList = [SELECT Id, Name, Monitor__c, Monitor_Txt__c, Activity_Name_EN__c,Activity_Name_FR__c, School_txt__c, Code__c, School_Year__c, My_Activity__c,Activity_name__c 
                  FROM Activity_Monitor__c Where School_txt__c='Woluwe' AND 
                School_Year__c =: currentYearString AND Active__c = true];
        set<Id> amIds = new set<id>();
        for(Activity_Monitor__c am : amList){
            amIds.add(am.Monitor__c);
        }
        system.debug('amIds:::'+amIds.size());
        
        conList = [SELECT id FROM Contact WHERE Id IN : amIds];
        for(Contact con : conList){
            conIds.add(con.id);
        }
        
        userList = [SELECT Id,ContactId FROM User WHERE ContactId IN : conIds];
        for(User usr : userList){
            addressee.add(usr.Id);
        }
        System.debug('addressee:::'+addressee);
        if(addressee.size() > 0){
            CustomNotificationType monitorNotification = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Monitor_Notification' LIMIT 1];
            System.debug('monitorNotification:::'+monitorNotification);
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Parent '+parentName+' reached on the gate');
            notification.setBody('Sample Body');
            notification.setNotificationTypeId(monitorNotification.Id);
            notification.setTargetId(amList[0].Id);
            notification.send(addressee);
        }
        return responseWrap;
    }
    private static List<Activity_Check__c> getActivityCheckList() {
        return [SELECT  Activity_Booking__c,ParentName__c,Authorized__c, StudentClass__c, Activity_Booking__r.ParentName__c,Student_Name__c, Activity_Booking__r.Student__c,CheckColorStatus__c,
        Activity_Booking__r.Activity_Type__c, Activity_Booking__r.Activity_Name__c,Activity_Booking__r.Authorization__c, Activity_Monitor_Txt__c,Activity_Monitor__c, Status__c,CheckInTime__c,CheckOut__c,ImageUrl__c
        FROM Activity_Check__c WHERE CreatedDate = Today AND Status__c ='Checked In' ORDER BY CreatedDate DESC];
    }
    public static ResponseWrapper updateColorStatus(string recordId){
        ResponseWrapper responseWrap = new ResponseWrapper();
        List<Activity_Check__c> acList = [SELECT  Id,CheckColorStatus__c FROM Activity_Check__c WHERE Id =: recordId];
        acList[0].CheckColorStatus__c = true;
        update acList;
        return responseWrap;
    }
    public static List<string> getCurrentTime(){
        List<String> currentTime = new List<String>();
        Datetime cDT = System.now();
        currentTime.add(cDT.format('HH:mm a'));
        system.debug('currentTime;;'+currentTime);
        return currentTime;
    }
    public class ResponseWrapper{
        @AuraEnabled public List<Activity_Check__c> activityCheckList{get;set;}
        @AuraEnabled public List<AccountContactRelation> AccConDetails{get;set;}
        @AuraEnabled public String status;
        @AuraEnabled public String errorMessage;
    }
}