public with sharing class DepartActivityController {
    @AuraEnabled (cacheable=true)
    public static DepartActivityService.ResponseWrapper getActivityCheck(){
        DepartActivityService.ResponseWrapper response = new DepartActivityService.ResponseWrapper();
        try {
            response = DepartActivityService.getActivityCheck();
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