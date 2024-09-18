public without sharing class OccasionalSupervisionController {
    @AuraEnabled
    public static OccasionalSupervisionService.ResponseWrapper getHouseholdStudent(string recordId){
        OccasionalSupervisionService.ResponseWrapper response = new OccasionalSupervisionService.ResponseWrapper();
        try {
            response = OccasionalSupervisionService.getHouseholdStudent(recordId);
            response.status = 'success';
            if(TestClassHelper.isThrowException){
                throw new TestClassHelper.TestClassException('Force Exception');
            }
        } catch (Exception e) {
            response.status = 'error';
            response.errorMessage = e.getMessage();
        }
        return response;
    }
    @AuraEnabled
    public static OccasionalSupervisionService.ResponseWrapper getPlannedActivity(string recordId){
        OccasionalSupervisionService.ResponseWrapper response = new OccasionalSupervisionService.ResponseWrapper();
        try {
            response = OccasionalSupervisionService.getPlannedActivity(recordId);
            response.status = 'success';
            if(TestClassHelper.isThrowException){
                throw new TestClassHelper.TestClassException('Force Exception');
            }
        } catch (Exception e) {
            response.status = 'error';
            response.errorMessage = e.getMessage();
        }
        return response;
    }
    
    @AuraEnabled
    public static OccasionalSupervisionService.ResponseWrapper occSupervisionSubmit(string occName, date occDate, string occPlannedActivity, string occClass, string scholYear, date startDate, date endDate, time startTime, time endTime, string activityName, string dayofWeek, string conId, string parentId){
        OccasionalSupervisionService.ResponseWrapper response = new OccasionalSupervisionService.ResponseWrapper();
        try {
            response = OccasionalSupervisionService.occSupervisionSubmit(occName,occDate,occPlannedActivity,occClass,scholYear,startDate,endDate,startTime,endTime, activityName, dayofWeek, conId, parentId);
            response.status = 'success';
            if(TestClassHelper.isThrowException){
                throw new TestClassHelper.TestClassException('Force Exception');
            }
        } catch (Exception e) {
            response.status = 'error';
            response.errorMessage = e.getMessage();
        }
        return response;
    }
}