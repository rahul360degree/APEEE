/*
	Created By : Rahul Yadav
	Created Date : 18-12-2023
	Description : This class will be excute ActivityBookingGPSBatch clas to update GPS on activity booking.
*/
global  class ActivityBookingGPSScheduler implements Schedulable{
    global void execute(SchedulableContext sc)
    {
        ActivityBookingGPSBatch b = new ActivityBookingGPSBatch();
        database.executeBatch(b);
    }
}