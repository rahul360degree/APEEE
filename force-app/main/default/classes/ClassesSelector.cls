public class ClassesSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                Class__c.Id,
                Class__c.Class__c,
                Class__c.Name,
                Class__c.Class_Type__c,
                Class__c.Location__c,
                Class__c.School__c,
                Class__c.Schoolyear__c
            };
    }

    public List<Class__c> selectByName(Set<String> names)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
            .setCondition('Name IN :names')
            .selectField('School__r.Name');

        return Database.query(queryfactory.toSOQL());
    }

    public List<Class__c> selectByNameSchoolAndYear(Set<String> names, Id schoolId, Id yearId)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
            .setCondition('Name IN :names AND School__c = :schoolId ANd Schoolyear__c = :yearId');
        return Database.query(queryfactory.toSOQL());
    }

    public Schema.SObjectType getSObjectType()
    {
        return Class__c.sObjectType;
    }

    public List<Class__c> selectById(Set<ID> idSet)
    {
        return (List<Class__c>) selectSObjectsById(idSet);
    }

}