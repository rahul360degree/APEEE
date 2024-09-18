public without sharing class SobjectUpsertUtility {

    @InvocableMethod(label = 'Upsert sObject' )
    public static List<ResponseWrapper> upsertObject(List<sObject> objRecords) {
        ResponseWrapper rw = new ResponseWrapper();
        try {
            upsert objRecords;
            rw.isSuccess = true;
        } catch(DmlException e) {
            String errorMessage = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += e.getDmlMessage(i);
            }
            rw.isSuccess = false;
            rw.errorMessage = errorMessage;
        }

        return new List<ResponseWrapper>{rw};
    }

    public class ResponseWrapper {
        @InvocableVariable public Boolean isSuccess;
        @InvocableVariable public String errorMessage;
    }
}