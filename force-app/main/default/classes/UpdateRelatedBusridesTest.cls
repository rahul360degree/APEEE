@isTest
public class UpdateRelatedBusridesTest {
	@testsetup
    static void testsetup(){
        Route__c rt = new Route__c();
        rt.Name = 'test';
        insert rt;
        Route__c rt1 = new Route__c();
        rt1.Name = 'test1';
        insert rt1;
        Busstop__c bs = new Busstop__c();
        bs.Name = 'test';
        insert bs;
        Busstop__c bs1 = new Busstop__c();
        bs1.Name = 'test1';
        insert bs1;
        RoutePlan__c routePln1 = new RoutePlan__c();
        routePln1.route__c = rt.Id;
        routePln1.Busstop__c = bs.Id;
        routePln1.time__c = Time.newInstance(07, 30, 00, 00);
        insert routePln1;
        RoutePlan__c routePln2 = new RoutePlan__c();
        routePln2.route__c = rt1.Id;
        routePln2.Busstop__c = bs1.Id;
        routePln2.time__c = Time.newInstance(07, 35, 00, 00);
        insert routePln2;
        Contact contest = new Contact();
        contest.LastName = 'test';
        insert contest;
        BusSubscription__c bp = new BusSubscription__c();
        bp.Student__c =  contest.Id;
        insert bp;
        BusRide__c bsride = new BusRide__c();
        bsride.time__c = '07:30';
        bsride.route__c= rt.Id;
        bsride.busstop__c = bs.Id;
        bsride.Subscription__c = bp.Id;
        bsride.Ridetype__c = 'Weekly';
        bsride.Startdate__c = Date.today();
        insert bsride;
    }
    @isTest 
    static void updateRelatedBusridesTest(){
        List<RoutePlan__c> routePlanList = [Select Id ,Route__c,Busstop__c,time__c From RoutePlan__c LIMIT 2];
        List<UpdateRelatedBusrides.RoutePlanWrapper> routeWrapper = new List<UpdateRelatedBusrides.RoutePlanWrapper>();
        UpdateRelatedBusrides.RoutePlanWrapper routeWrap = new UpdateRelatedBusrides.RoutePlanWrapper();
        routeWrap.oldRoutePlan = routePlanList[0];
        routeWrap.newRoutePlan = routePlanList[1];
        routeWrapper.add(routeWrap);
        Test.startTest();
        UpdateRelatedBusrides.updateRelatedBusrides(routeWrapper);
        Test.stopTest();
    }
}