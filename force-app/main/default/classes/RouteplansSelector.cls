public class RouteplansSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                RoutePlan__c.Id,
                RoutePlan__c.Route__c,
                RoutePlan__c.Busstop__c,
                RoutePlan__c.Bus_Stop_Name__c,
                RoutePlan__c.Is_Active__c,
                RoutePlan__c.Latitude__c,
                RoutePlan__c.Longitude__c,
                RoutePlan__c.Time_and_Busstopp_Name__c,
                RoutePlan__c.Departure_Time__c,
                RoutePlan__c.Busstop_Code__c,
                RoutePlan__c.Remaining_Capacity__c,
                RoutePlan__c.TimeTxT__c,
                RoutePlan__c.Time__c
            };
    }
/*

SELECT Id, Route__c, Busstop__c, Bus_Stop_Name__c, Is_Active__c , Latitude__c, Longitude__c, Time_and_Busstopp_Name__c, Departure_Time__c, Busstop_Code__c, Remaining_Capacity__c, TimeTxT__c, Time__c
                                                FROM RoutePlan__c
                                                WHERE Route__c = :routeId
                                                ORDER BY Time__c asc

*/
    public List<RoutePlan__c> selectByRouteId(Set<Id> idSet)
    {
        fflib_QueryFactory queryfactory = newQueryFactory()
            .setCondition('Route__c IN :idSet')
            .setOrdering(RoutePlan__c.Time__c, fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.query(queryfactory.toSOQL());
    }

    public Schema.SObjectType getSObjectType()
    {
        return RoutePlan__c.sObjectType;
    }

    public List<RoutePlan__c> selectById(Set<ID> idSet)
    {
        return (List<RoutePlan__c>) selectSObjectsById(idSet);
    }

}