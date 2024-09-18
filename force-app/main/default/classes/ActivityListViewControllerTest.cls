@isTest
public class ActivityListViewControllerTest {
    @isTest
    public static void getActivityMetadataTest(){
        List<ActivityListView__mdt> alvList = new List<ActivityListView__mdt>();
        alvList = [SELECT id,DeveloperName,MasterLabel,ObjectName__c FROM ActivityListView__mdt];
        ActivityListViewController.getActivityMetadata();
    }   
}