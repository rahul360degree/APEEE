public with sharing class ActivityPrintViewService {
    
    public static ResponseWrapper getStudentByActivity(){
        ResponseWrapper responseWrap = new ResponseWrapper();
        List<Activity_Booking__c> activityBookings = new List<Activity_Booking__c>();
        activityBookings = [SELECT id, Name,Activity_Name__c, Student_Name__c, Student__c,Student__r.Name,Status__c,Student__r.Class1__r.Name FROM Activity_Booking__c WHERE Status__c='Booked' LIMIT 20];
        System.debug('activityBookings:::'+activityBookings);
        if(!activityBookings.isEmpty()){
            responseWrap.activityBookingObj = activityBookings;
        }
         return responseWrap;
    }
    public class ResponseWrapper{
        public List<Activity_Booking__c> activityBookingObj{get;set;}
        public String status{get;set;}
        public String errorMessage{get;set;}
    }
}