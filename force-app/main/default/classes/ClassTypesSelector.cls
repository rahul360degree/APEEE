public class ClassTypesSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                ClassType__c.Id,
                ClassType__c.Name,
                ClassType__c.Level__c,
                ClassType__c.School__c,
                ClassType__c.Name,
                ClassType__c.Language__c
            };
    }

    public Schema.SObjectType getSObjectType()
    {
        return ClassType__c.sObjectType;
    }

    public List<ClassType__c> selectBySchool(Id schoolId)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
                .setCondition('School__c = :schoolId');
        return Database.query(queryfactory.toSOQL());
    }

    public List<ClassType__c> selectById(Set<ID> idSet)
    {
        return (List<ClassType__c>) selectSObjectsById(idSet);
    }

}