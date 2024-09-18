public with sharing class GPSActivityBookingController {
    @AuraEnabled
    public static List<ActivityBooking__mdt> getGPSMetadata(){
        List<ActivityBooking__mdt> activityListView = ActivityBooking__mdt.getAll().values();
        return activityListView;
    }
}