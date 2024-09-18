public class SchoolsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                School__c.Id,
                School__c.Name,
                School__c.Location__c
            };
    }

    public List<School__c> selectBySchoolName(Set<String> names)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
            .setCondition('Name IN :names');
        return Database.query(queryfactory.toSOQL());
    }

    public List<School__c> selectAll()
    {
        fflib_QueryFactory queryfactory = newQueryFactory();
        return Database.query(queryfactory.toSOQL());
    }

    public Schema.SObjectType getSObjectType()
    {
        return School__c.sObjectType;
    }

    public List<School__c> selectById(Set<ID> idSet)
    {
        return (List<School__c>) selectSObjectsById(idSet);
    }

}