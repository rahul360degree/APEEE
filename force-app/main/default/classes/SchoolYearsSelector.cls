public class SchoolYearsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                SchoolYear__c.Id,
                SchoolYear__c.Name
            };
    }

    public List<SchoolYear__c> selectByYearName(Set<String> names)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
        .setCondition('Name IN :names');
        return Database.query(queryfactory.toSOQL());
    }

    public List<SchoolYear__c> selectActive()
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
            .setCondition('IsActive__c = true');
        return Database.query(queryfactory.toSOQL());
    }
    

    public List<SchoolYear__c> selectAll()
    {
        return Database.query(newQueryFactory().toSOQL());
    }

    public Schema.SObjectType getSObjectType()
    {
        return SchoolYear__c.sObjectType;
    }

    public List<SchoolYear__c> selectById(Set<ID> idSet)
    {
        return (List<SchoolYear__c>) selectSObjectsById(idSet);
    }

}