public with sharing class BusrouteMapController 
{
    private static final String LINE_TEMPLATE = '<b>{0}</b> : {1}<br /> ';
    private static Map<String, SObjectField> DescriptionFieldsByLabel = new Map<String, SObjectField>{
        'Departure' => RoutePlan__c.TimeTxT__c
    };

    private static RouteplansSelector planSelector = (RouteplansSelector)Application.Selector.newInstance(RoutePlan__c.SObjectType);
    private static BusstopsSelector stopSelector = (BusstopsSelector)Application.Selector.newInstance(Busstop__c.SObjectType);

    public BusrouteMapController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Marker> getMarkersForRoute (Id routeId)
    {
        try
        {
            List<Marker> markersToReturn = new List<Marker>();

            List<RoutePlan__c> plansForRoute = planSelector.selectByRouteId(new Set<Id>{routeId});
            
            system.debug ('plansForRoute : ' + JSON.serialize(plansForRoute));

            /*[SELECT Id, Route__c, Busstop__c, Bus_Stop_Name__c, Is_Active__c , Latitude__c, Longitude__c, Time_and_Busstopp_Name__c, Departure_Time__c, Busstop_Code__c, Remaining_Capacity__c, TimeTxT__c, Time__c
                                                FROM RoutePlan__c
                                                WHERE Route__c = :routeId
                                                ORDER BY Time__c asc];
*/
            Set<Id> busstopIds = new Set<Id>();

            for (RoutePlan__c plan : plansForRoute)
            {
                busstopIds.add(plan.Busstop__c);
            }

            List<Busstop__c> busstopsWithRides = stopSelector.selectByIdWithRides(busstopIds);

            system.debug ('busstopsWithRides : ' + JSON.serialize(busstopsWithRides));

            /*[ SELECT Id, Name, (SELECT Id FROM Bus_registrations__r WHERE Startdate__c <= TODAY AND (Enddate__c >= TODAY OR Enddate__c = null) AND Status__c = 'Approved') 
                                               FROM Busstop__c
                                               WHERE Id IN :busstopIds];*/

            Map<Id, Integer> nrOfChildrenForStop = new Map<Id, Integer>();

            for (Busstop__c currentStop : busstopsWithRides)
            {
                nrOfChildrenForStop.put(currentStop.Id, currentStop.Bus_registrations__r?.size());
            }

            for (RoutePlan__c currentPlan : plansForRoute)
            {
                markersToReturn.add(getMarkerFromRouteplan(currentPlan, nrOfChildrenForStop.get(currentPlan.Busstop__c)));
            }
/* 
SOQL query:  SELECT Id, Route__c, Busstop__c, Bus_Stop_Name__c, Is_Active__c, Departure_time_route__c, Latitude__c, Longitude__c, Time_and_Busstopp_Name__c, Departure_Time__c, Busstop_Code__c, Municipality_from_BusStop__c, TimeTxT__c, School__c, Time__c 
             FROM RoutePlan__c
             WHERE Route__c = 
*/

            return markersToReturn;
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Marker getMarkerFromRouteplan(RoutePlan__c plan, Integer nrOfChildren)
    {
        Marker m = new Marker();
        m.description = getDescription(plan);
        m.description += addLine('Number of Children' , (nrOfChildren == null)? 0 : nrOfChildren);
        m.icon = 'utility:signpost';
        m.location = new Location(plan.Latitude__c, plan.Longitude__c);
        m.title = plan.Bus_Stop_Name__c;
        m.value = plan.Busstop__c;
        return m;
    }

    private static String getDescription(RoutePlan__c plan)
    {
        String description = '';
        for (String label : DescriptionFieldsByLabel.keySet())
        {
            description += addLine(label, plan.get(DescriptionFieldsByLabel.get(label)));
        }
        
        return description;
    }

    private static String addLine(String label, Object value)
    {
        return String.format(LINE_TEMPLATE, new List<Object>{label, value});
    }

    public class Marker
    {
        // public Marker()
        // {
        //     this.mapIcon = new MapIcon();
        // }

        @AuraEnabled
        public Location location;
        // @AuraEnabled
        // public MapIcon mapIcon;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String icon;
    }

    public class Location
    {

        public Location(Decimal latitude, Decimal longitude)
        {
            this.Latitude = String.valueOf(latitude);
            this.Longitude = String.valueOf(longitude);
            this.Street = ' ';
        }

        @AuraEnabled
        public String Street;

        @AuraEnabled
        public String Latitude;
        @AuraEnabled
        public String Longitude;
    }

    // public class MapIcon
    // {
    //     @AuraEnabled
    //     public String path = 'M 37.181949,59.563031 V 196.86421 H 106.0904 l 68.39273,39.90609 v -39.90609 l 0.002,-42.72504 V 59.566648 Z m 35.15806,30.995007 h 66.985571 c 1.31191,0 2.3828,1.071959 2.3828,2.383835 v 2.534211 h 8.49716 c 1.36289,0 2.47065,1.106905 2.47065,2.471166 l 0.003,12.62404 h -0.004 c 0,1.36563 -1.10828,2.47065 -2.47117,2.47065 -1.36289,0 -2.47065,-1.10639 -2.47065,-2.47065 l -0.002,-10.15494 h -6.02443 v 61.17559 c 0,1.30913 -1.07093,2.38229 -2.3828,2.38229 h -2.24069 v 4.65088 c 0,0.91916 -0.75085,1.66914 -1.66864,1.66914 h -4.16977 c -0.91916,0 -1.66915,-0.75136 -1.66915,-1.66914 v -4.65088 H 82.113056 v 4.65088 c 0,0.91916 -0.750671,1.66914 -1.667082,1.66914 h -4.172873 c -0.916411,0 -1.668632,-0.75136 -1.668632,-1.66914 v -4.65088 h -2.26446 c -1.31191,0 -2.383835,-1.07179 -2.383835,-2.38229 l -0.0016,-61.17559 h -6.022888 v 10.15649 c 0,1.36563 -1.106731,2.47065 -2.469616,2.47065 -1.365638,0 -2.47065,-1.10639 -2.47065,-2.47065 V 97.94725 c 0,-1.365637 1.106387,-2.471166 2.47065,-2.471166 h 8.494054 v -2.534211 c 0,-1.31191 1.071959,-2.383835 2.383835,-2.383835 z m 1.191657,12.632302 c -0.183277,0.3514 -0.290936,0.75912 -0.290936,1.19321 v 37.18636 c 0,1.31191 0.974101,2.38642 2.164726,2.38642 h 60.854164 c 1.18925,0 2.16524,-1.07454 2.16524,-2.38642 v -37.18636 c 0,-0.43272 -0.10645,-0.83906 -0.29249,-1.19321 -0.37757,0.71381 -1.07591,1.19321 -1.87378,1.19321 H 75.405456 c -0.796502,0 -1.497587,-0.4794 -1.87379,-1.19321 z m 12.432834,45.9326 c -1.798354,0 -3.263368,1.46587 -3.263368,3.26285 0,1.79557 1.4678,3.26336 3.263368,3.26336 1.798354,0 3.26285,-1.46779 3.26285,-3.26336 0.0028,-1.79557 -1.46312,-3.26285 -3.26285,-3.26285 z m 39.85286,0 c -1.79835,0 -3.26595,1.46587 -3.26595,3.26285 0,1.79557 1.46763,3.26336 3.26595,3.26336 1.79836,0 3.26337,-1.46779 3.26337,-3.26336 0.003,-1.79557 -1.46501,-3.26285 -3.26337,-3.26285 z m -48.714851,1.19579 c -1.138275,0 -2.067057,0.92999 -2.067057,2.06964 0,1.13552 0.928782,2.06706 2.067057,2.06706 1.138272,0 2.067057,-0.93016 2.067057,-2.06706 0,-1.13965 -0.928785,-2.06964 -2.067057,-2.06964 z m 57.580461,0 c -1.13965,0 -2.06861,0.92999 -2.06861,2.06964 0,1.13552 0.92896,2.06706 2.06861,2.06706 1.13552,0 2.06706,-0.93016 2.06706,-2.06706 -0.003,-1.13965 -0.93154,-2.06964 -2.06706,-2.06964 z';
    //     @AuraEnabled
    //     public String fillColor = '#000000';
    //     @AuraEnabled
    //     public Decimal fillOpacity = 1;
    //     @AuraEnabled
    //     public Decimal strokeWeight = 0.352778;
    //     @AuraEnabled
    //     public Decimal scale = .25;
    // }

}