public class GetAssignedRecordTypeInfo {
    
    @InvocableMethod(label = 'Get Record Type' Category='RecordType')
    public static List<List<String>> getRecordTypeList(List<String> recordIds){
        List<List<String>> returnValue = new List<List<String>>();
        List<String> recordTypeList = new List<String>();
        for (RecordTypeInfo rectype : Schema.describeSObjects(new List<String>{'Contact'}).get(0).getRecordTypeInfos()) {
            if (rectype.isAvailable() && !rectype.isMaster()) {
               recordTypeList.add(rectype.getName()); 
            }
        }
        for(String str: recordIds) {
            returnValue.add(recordTypeList);
        }
        return returnValue;
    }
}