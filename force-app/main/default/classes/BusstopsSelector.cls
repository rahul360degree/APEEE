public class BusstopsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                Busstop__c.Id
            };
    }

/*

[ SELECT Id, Name, (SELECT Id FROM Bus_registrations__r WHERE Startdate__c <= TODAY AND (Enddate__c >= TODAY OR Enddate__c = null) AND Status__c = 'Approved') 
                                               FROM Busstop__c
                                               WHERE Id IN :busstopIds];

*/

    public List<Busstop__c> selectByIdWithRides (Set<Id> idSet)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
            .setCondition('Id IN :idSet');

        fflib_QueryFactory ridesfactory = queryfactory
            .subselectQuery('Bus_registrations__r')
            .selectFields(new List<Schema.SObjectField>{Busride__c.Id})
            .setCondition('Startdate__c <= TODAY AND (Enddate__c >= TODAY OR Enddate__c = null) AND Status__c = \'Approved\'');
        
        return Database.query(queryfactory.toSOQL());
    }

    public Schema.SObjectType getSObjectType()
    {
        return Busstop__c.sObjectType;
    }

    public List<Busstop__c> selectById(Set<ID> idSet)
    {
        return (List<Busstop__c>) selectSObjectsById(idSet);
    }

}