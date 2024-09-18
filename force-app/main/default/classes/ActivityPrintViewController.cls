public with sharing class ActivityPrintViewController {
    public static List<ResponseWrapper> responseWrap{get;set;}
    public ActivityPrintViewController(){
        responseWrap = new List<ResponseWrapper>();
    }
    public static void getStudentByActivity(){
        ResponseWrapper rw = new ResponseWrapper();
        List<Activity_Booking__c> activityBookings = new List<Activity_Booking__c>();
        activityBookings = [SELECT id, Name,Activity_Name__c, Student_Name__c, Student__c,Student__r.Name,Status__c,Student__r.Class1__r.Name FROM Activity_Booking__c WHERE Status__c='Booked' LIMIT 20];
        System.debug('activityBookings:::'+activityBookings);
        if(!activityBookings.isEmpty()){
            for(Activity_Booking__c ab : activityBookings){
                rw.studentName = ab.Student_Name__c;
                rw.activityName = ab.Activity_Name__c;
                responseWrap.add(rw);
            }
        }
        System.debug('responseWrap:::'+responseWrap);
    }
    public class ResponseWrapper{
        public string studentName{get;set;}
        public string activityName{get;set;}
        public string className{get;set;}
        public string dayValue{get;set;}
        public string timeValue{get;set;}
    }
}