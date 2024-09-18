public class UpdateRelatedBusrides {

   public class RoutePlanWrapper{
       @InvocableVariable public RoutePlan__c oldRoutePlan;
       @InvocableVariable public RoutePlan__c newRoutePlan;
    }
	@InvocableMethod(label='Update Related Busrides' description='Update Related Busrides')
    public static void updateRelatedBusrides(List<RoutePlanWrapper> routePlans){

        List<BusRide__c> busRideListToUpdate = new List<BusRide__c>();

        Map<String, RoutePlan__c> oldRoutePlanVsNewRoutePlanMap = new Map<String, RoutePlan__c>();
        
        Set<Id> busStopIdSet = new Set<Id>();
        Set<Id> RouteIdSet = new Set<Id>();
        Set<String> RouteTimeSet = new Set<String>();
        
        for(RoutePlanWrapper rpw: routePlans) {
            
        
            busStopIdSet.add(rpw.oldRoutePlan.Busstop__c);
            RouteIdSet.add(rpw.oldRoutePlan.Route__c);
            String timeasString = String.valueOf(rpw.oldRoutePlan.time__c);
            RouteTimeSet.add(timeAsString.substring(0,5));

            oldRoutePlanVsNewRoutePlanMap.put(rpw.oldRoutePlan.Busstop__c + '#' + rpw.oldRoutePlan.Route__c  + '#' + timeAsString.substring(0,5) , rpw.newRoutePlan);
        }
       	
        for(BusRide__c br: [SELECT Id, Name, Busstop__c, Route__c, Time__c FROM BusRide__c WHERE Busstop__c IN: busStopIdSet AND Route__c IN: RouteIdSet AND Time__c IN: RouteTimeSet ]) {
           
            String timeAsString = String.valueOf(oldRoutePlanVsNewRoutePlanMap.get(br.Busstop__c + '#' + br.Route__c + '#' + br.time__c).Time__c);
            busRideListToUpdate.add(new BusRide__c( Id = br.Id, 
                                                   Route__c = oldRoutePlanVsNewRoutePlanMap.get(br.Busstop__c + '#' + br.Route__c + '#' + br.time__c).Route__c, 
                                                   Time__c = timeAsString.substring(0,5),
                                   				   Busstop__c = oldRoutePlanVsNewRoutePlanMap.get(br.Busstop__c + '#' + br.Route__c + '#' + br.time__c).Busstop__c
                                                  )
                                   );
        System.debug('busRideListToUpdate --' + busRideListToUpdate);
        }
        
        if(!busRideListToUpdate.isEmpty()) {
            update busRideListToUpdate;
        }
        
    }
}