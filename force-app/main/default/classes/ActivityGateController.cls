public with sharing class ActivityGateController {
    @AuraEnabled (cacheable=true)
    public static ActivityGateService.ResponseWrapper getActivityCheck(){
        ActivityGateService.ResponseWrapper response = new ActivityGateService.ResponseWrapper();
        try {
            response = ActivityGateService.getActivityCheck();
            system.debug('response:::'+response);
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
    public static ActivityGateService.ResponseWrapper getContactDetails(string recordId){
        ActivityGateService.ResponseWrapper response = new ActivityGateService.ResponseWrapper();
        try {
            response = ActivityGateService.getContactDetails(recordId);
            response.status = 'success';
            if(TestClassHelper.isThrowException){
                throw new TestClassHelper.TestClassException('Force Exception');
            }
        } catch (Exception e) {
            response.status = 'error';
            response.errorMessage = e.getMessage();
            system.debug('error message:::0'+e.getMessage());
            system.debug('error message:::0'+e.getLineNumber());
        }
        return response;
    }
    @AuraEnabled
    public static ActivityGateService.ResponseWrapper checkOutStudents(List<AccountContactRelation> selectedRecords, string activityCheckId){
        ActivityGateService.ResponseWrapper response = new ActivityGateService.ResponseWrapper();
        System.debug('activityCheckId::-'+activityCheckId);
        try {
            response = ActivityGateService.checkOutStudents(selectedRecords, activityCheckId);
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
    public static ActivityGateService.ResponseWrapper sendNotificationToMonitors(string parentName){
       System.debug('parentName:::'+parentName);
        ActivityGateService.ResponseWrapper response = new ActivityGateService.ResponseWrapper();
        try {
            response = ActivityGateService.sendNotificationToMonitors(parentName);
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
    public static ActivityGateService.ResponseWrapper updateColorStatus(string recordId){
        ActivityGateService.ResponseWrapper response = new ActivityGateService.ResponseWrapper();
        try {
            response = ActivityGateService.updateColorStatus(recordId);
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