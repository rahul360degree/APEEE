public with sharing class CloneSubscriptionsController {
  

    @AuraEnabled
    public static List<SchoolYear__c> getSchoolYears(){
        return [SELECT Id, Name FROM SchoolYear__c LIMIT 1000];
    }

    @AuraEnabled
    public static void createSubscriptionHandler(String fromYear, String toYear, String subscritpionType, String schoolYear, String startDate, String endDate){
       
            SubscriptionCloneBatch batch = new SubscriptionCloneBatch(fromYear, toYear, subscritpionType, schoolYear, startDate, endDate);
            Database.executeBatch(batch, 1);
       
    }


}