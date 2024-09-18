public without sharing class SubscriptionClone {
    @InvocableMethod(label = 'Clone Subscription' )
    public static void cloneSubscription(List<cloneWrapper> cloneData) {
        cloneWrapper cw = cloneData[0];
        SubscriptionCloneBatch batch = new SubscriptionCloneBatch(cw.cloneFromId, cw.cloneToId, cw.action);
        Database.executeBatch(batch, 1);
    }

    public class cloneWrapper {
        @InvocableVariable public String cloneFromId;
        @InvocableVariable public String cloneToId;
        @InvocableVariable public String action;
    }
}