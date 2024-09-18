public with sharing class DepartActivityService {
    public static ResponseWrapper getActivityCheck() {
        ResponseWrapper responseWrap = new ResponseWrapper();
        List<Activity_Check__c> acList = new List<Activity_Check__c>();
        acList =  [SELECT  Activity_Booking__c,StudentClass__c,ParentName__c, Activity_Booking__r.ParentName__c,Student_Name__c, Activity_Booking__r.Student__c,CheckColorStatus__c,
        Activity_Booking__r.Activity_Type__c,GPS_Groupe__c, Activity_Booking__r.Activity_Name__c, Activity_Monitor_Txt__c,Activity_Monitor__c, Status__c,CheckInTime__c,CheckOut__c,ImageUrl__c
        FROM Activity_Check__c WHERE CreatedDate = Today AND CheckColorStatus__c = true AND Status__c = 'Checked In'];
        if(!acList.isEmpty()){
            responseWrap.activityCheckList = acList;
        }
        return responseWrap;
    }
    public class ResponseWrapper{
        @AuraEnabled public List<Activity_Check__c> activityCheckList{get;set;}
        @AuraEnabled public String status;
        @AuraEnabled public String errorMessage;
    }
}