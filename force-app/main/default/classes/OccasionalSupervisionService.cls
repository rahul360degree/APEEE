public without sharing class OccasionalSupervisionService {
    public static ResponseWrapper getHouseholdStudent(string recordId){
        ResponseWrapper responseWrap = new ResponseWrapper();
        set<Id> accids = new set<Id>();
        set<Id> userid = new set<Id>();
        List<Contact> conList = new List<Contact>();
        conList = [SELECT Id, Name, User__c,AccountId FROM Contact WHERE User__c =: recordId];
        for(Contact con : conList){
            accids.add(con.AccountId);
            userid.add(con.User__c);
        }
        List<User> userObj = [SELECT id,ContactId FROM User WHERE id IN : userid];
        for(User usr : userObj){
            responseWrap.userContactId = usr.ContactId;
        }
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        acrList = [SELECT Id, ContactId,Contact.Name, AccountId, Roles,Relation__c FROM AccountContactRelation WHERE AccountId IN : accids AND (Relation__c = 'Daughter' OR Relation__c = 'Son')];
        if(acrList.size() > 0){
            responseWrap.accConList = acrList;
        }
        return responseWrap;
    }
    public static ResponseWrapper getPlannedActivity(string recordId){
        ResponseWrapper responseWrap = new ResponseWrapper();
        set<Id> conId = new set<Id>();
        set<Id> classId = new set<Id>();
        set<string> SCHOOL_NAME = new set<string>();

        Integer currentYear = System.now().year();
        String currentYearRange = (currentYear - 1) + '-' + currentYear;
        system.debug('currentYearRange--'+currentYearRange);

        Date d = System.today();
        Datetime dt = (DateTime)d;
        String dayOfWeek = dt.format('EEEE');
        List<AccountContactRelation> acrList = [SELECT Id,ContactId,AccountId FROM AccountContactRelation WHERE Id =: recordId];
        for(AccountContactRelation acr : acrList){
            if(acr.ContactId != null){
                conId.add(acr.ContactId);
            }
        }
        List<ClassEnrollment__c> ceList = [SELECT Id,Contact__c,School__c,Class_txt__c,Class__c,School_year_txt__c FROM ClassEnrollment__c WHERE Contact__c IN : conId AND School_year_txt__c =: currentYearRange];
        System.debug('ceList--'+ceList);
        if(!ceList.isEmpty()){
            for(ClassEnrollment__c ce : ceList){
                responseWrap.className = ce.Class_txt__c;
                responseWrap.classId = ce.Class__c;
                responseWrap.schollName = ce.School__c;
                SCHOOL_NAME.add(ce.School__c);
            }
        }
        List<Planned_Activity__c> paList = new List<Planned_Activity__c>();
        paList = [SELECT id,Name,Code__c,Day__c,School_Year_Txt__c,End_Date__c,End_Time__c,School_Year__c,School__c,Start_Date__c,Start_Time__c,School_txt__c,Activity_Name_EN__c,Class__c FROM Planned_Activity__c WHERE School_Year_Txt__c =: currentYearRange AND School_txt__c IN : SCHOOL_NAME AND Activity_Name_EN__c =: 'Occassional Supervision'];
        System.debug('paList:::='+paList);
        if(!paList.isEmpty()){
            responseWrap.plannedActivityList = paList;
        }
        return responseWrap;
    }
    public static ResponseWrapper occSupervisionSubmit(string occName, date occDate, string occPlannedActivity, string occClass, string scholYear, date startDate, date endDate, time startTime, time endTime, string activityName, string dayofWeek, string conId, string parentId){
        ResponseWrapper responseWrap = new ResponseWrapper();
            OccasionalSupervision__c occs = new OccasionalSupervision__c();
            occs.Name = occName;
            occs.Date__c = occDate;
            occs.PlannedActivity__c = occPlannedActivity;
            occs.Class__c = occClass;
            occs.SchoolYear__c = scholYear;
            occs.StartDate__c = startDate;
            occs.EndDate__c = endDate;
            occs.EndTime__c = endTime;
            occs.StartTime__c = startTime;
            occs.ActivityNameEN__c = activityName;
            occs.DayofWeek__c = dayofWeek;
            occs.Student__c = conId;
            occs.Parent__c = parentId;
            occs.StatusofApproval__c = 'Requested';
            insert occs;
            return responseWrap;
    }
    public class ResponseWrapper{
        @AuraEnabled public List<AccountContactRelation> accConList{get;set;}
        @AuraEnabled public List<Planned_Activity__c> plannedActivityList{get;set;}
        @AuraEnabled public string className{get;set;}
        @AuraEnabled public string userContactId{get;set;}
        @AuraEnabled public string classId{get;set;}
        @AuraEnabled public string schollName{get;set;}
        @AuraEnabled public String status;
        @AuraEnabled public String errorMessage;
    }
}