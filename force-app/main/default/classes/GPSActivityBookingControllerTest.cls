@IsTest
public class GPSActivityBookingControllerTest {
@isTest
    public static void getGPSMetadataTest(){
        List<ActivityBooking__mdt> alvList = new List<ActivityBooking__mdt>();
        alvList = [SELECT id,DeveloperName,MasterLabel,ObjectName__c FROM ActivityBooking__mdt];
        GPSActivityBookingController.getGPSMetadata();
    } 
}