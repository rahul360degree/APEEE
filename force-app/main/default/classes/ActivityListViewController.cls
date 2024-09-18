public class ActivityListViewController {
    @AuraEnabled
    public static List<ActivityListView__mdt> getActivityMetadata(){
        List<ActivityListView__mdt> activityListView = ActivityListView__mdt.getAll().values();
        return activityListView;
    }
}