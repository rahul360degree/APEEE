public class ClassEnrollmentsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                ClassEnrollment__c.Id,
                ClassEnrollment__c.Class__c,
                ClassEnrollment__c.Contact__c,
                ClassEnrollment__c.Enroll_End_Date__c,
                ClassEnrollment__c.School__c,
                ClassEnrollment__c.School_Year__c
            };
    }

    public Schema.SObjectType getSObjectType()
    {
        return ClassEnrollment__c.sObjectType;
    }
   
    public List<ClassEnrollment__c> selectById(Set<ID> idSet)
    {
        return (List<ClassEnrollment__c>) selectSObjectsById(idSet);
    }
   
}