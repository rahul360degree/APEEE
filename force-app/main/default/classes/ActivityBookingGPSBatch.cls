/*
	Created By : Rahul Yadav
	Created Date : 18-12-2023
	Description : This class will update GPS on Child contact whenever new GPS is inserted. this class will be excute once a week as per requirment.
*/
global  class ActivityBookingGPSBatch implements Database.Batchable<sObject> {
	 global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id,Name, Student__c,OIB__c FROM Activity_Booking__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Activity_Booking__c> scope) {
        List<OIBGPS__c> oibList = new List<OIBGPS__c>();
        List<Activity_Booking__c> abToUpdate = new List<Activity_Booking__c>();
        oibList = [SELECT id, Name,School_Contact_ID__c,Contact__c FROM OIBGPS__c];
        map<string,string> conIdvsdpsId = new map<string, string>();
        for(OIBGPS__c oib : oibList){
            if(oib.Contact__c != null){
                conIdvsdpsId.put(oib.Contact__c,oib.id);
            }
        }
        for(Activity_Booking__c ab : scope){
            if(ab.OIB__c == null && ab.OIB__c ==){

            }
            if(conIdvsdpsId.containsKey(ab.Student__c)){
                ab.OIB__c = conIdvsdpsId.get(ab.Student__c);
            }
            abToUpdate.add(ab);
        }
        update abToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}