/*
Created By : Rahul Yadav
Created Date : 20-12-2023
Description : This class will excute once in a week to update main parent and second parent field on activity booking from related child record.
*/
global with sharing class ActivityBookingBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT id,Student__r.AccountId,Parent__c FROM Activity_Booking__c';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Activity_Booking__c> scope) {
        Set<Id> accIds = new Set<Id>();
        List<Activity_Booking__c> activityBookingToUpdate = new List<Activity_Booking__c>();
        for(Activity_Booking__c ab : scope ) {
            system.debug(ab.Id);
            accIds.add(ab.Student__r.AccountId);
        }
        Map<String, List<AccountContactRelation>> accIdVsAcrListMap = new Map<String, List<AccountContactRelation>>();
        
        for(AccountContactRelation acr: [SELECT ID, AccountId, ContactId, Relation__c FROM AccountContactRelation WHERE AccountId IN: accIds]) {
            if(!accIdVsAcrListMap.containsKey(acr.AccountId)) {
                accIdVsAcrListMap.put(acr.AccountId, new List<AccountContactRelation>{});
            }
            accIdVsAcrListMap.get(acr.AccountId).add(acr);
        }
        
        System.debug(accIdVsAcrListMap);
        if(accIdVsAcrListMap != null){
            for(Activity_Booking__c ab: scope ) {
                AccountContactRelation father;
                AccountContactRelation mother;
                AccountContactRelation stepFather;
                AccountContactRelation stepMother;
                if(accIdVsAcrListMap.get(ab.Student__r.AccountId) != null){
                    for(AccountContactRelation acr: accIdVsAcrListMap.get(ab.Student__r.AccountId)) {
                        if(acr.Relation__c == 'Father') {
                            father = acr;
                        } else if(acr.Relation__c == 'Mother') {
                            mother = acr;
                        } else if(acr.Relation__c == 'StepFather') {
                            stepFather = acr;
                        } else if(acr.Relation__c == 'StepMother') {
                            stepMother = acr;
                        }
                    }
                }
                System.debug(father);
                System.debug(mother);
                if((father != null && ab.Parent__c == father.ContactId) || (stepFather != null && ab.Parent__c == stepFather.ContactId)) {
                    if(mother != null) {
                        System.debug('Inside Mother');
                        ab.SecondParent__c = mother.ContactId;
                    } else if(stepMother != null) {
                        ab.SecondParent__c = stepMother.ContactId;
                    }
                } else if((mother != null && ab.Parent__c == mother.ContactId) || (stepMother != null && ab.Parent__c == stepMother.ContactId)) {
                    if(father != null) {
                        ab.SecondParent__c = father.ContactId;
                    } else if(stepFather != null) {
                        ab.SecondParent__c = stepFather.ContactId;
                    }
                }
                activityBookingToUpdate.add(ab);
            }
        }
        update activityBookingToUpdate;
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}