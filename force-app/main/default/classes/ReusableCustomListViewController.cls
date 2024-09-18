public with sharing class ReusableCustomListViewController {
    public ReusableCustomListViewController() {

    }
    @AuraEnabled(cacheable = true)  
    public static List <sObject> relatedListRecord(String listValues, String recordId) {
        System.debug(listValues);
        List<String> strList = listValues.split('-'); 
        String strObject = strList.get(0);
        String strFields = strList.get(1);
        String strRelatedField = strList.get(2);
        String strAccountId = recordId;
 
         
 
        List<sObject> listRecs = new List<sObject>();
        String strSOQL = 'SELECT Id, ' + strFields + ' FROM ' + strObject;
 
        if (String.isNotBlank(strAccountId)){
            strSOQL  += ' WHERE ' + strRelatedField+ ' = \'' + strAccountId + '\'';
        }  
         
        strSOQL += ' LIMIT 25';
        system.debug( 'SOQL is ' + strSOQL );
        listRecs = Database.query( strSOQL );
        return listRecs;
    }
}