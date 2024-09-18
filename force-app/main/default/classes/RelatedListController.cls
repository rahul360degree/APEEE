public with sharing class RelatedListController {
    @AuraEnabled
    public static List<sObject> fetchData(String fieldNames, String objectApiName, String parentId, String lookupFieldApiName, String filters){

        String query = 'SELECT ' + fieldNames + ' FROM ' + objectApiName;

        if(String.IsNotBlank(parentId) && String.IsNotBlank(lookupFieldApiName)) {
            query += ' WHERE ' + lookupFieldApiName + ' =: parentId';

            if(String.IsNotBlank(filters)) {
                query += ' AND ' + filters;
            }
        } else if(String.IsNotBlank(filters)) {
            query += ' WHERE ' + filters;
        }
        
        query += ' LIMIT 1000';

        return Database.query(query);       
    }
}