public with sharing class relatedListComponentController {
    public relatedListComponentController() {

    }
    @AuraEnabled
    public static List<sObject> getRelatedListRecords(String recordId, String fields, String relatedObjectAPIName, String parentFieldAPIName){
        try {
            List<sObject> recList = new List<sObject>();
            String query = 'SELECT ' + fields + ' FROM ' + relatedObjectAPIName + ' WHERE ' + parentFieldAPIName + ' = \'' + recordId + '\' LIMIT 10000';
            System.debug(query + ' ---- query');
            recList = Database.query(query);
            system.debug(recList);
            return recList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}