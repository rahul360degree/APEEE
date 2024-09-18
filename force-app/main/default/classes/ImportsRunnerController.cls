public with sharing class ImportsRunnerController 
{

    private static SchoolYearsSelector yearSelector = (SchoolYearsSelector)Application.Selector.newInstance(SchoolYear__c.SObjectType);
    private static SchoolsSelector schoolSelector = (SchoolsSelector)Application.Selector.newInstance(School__c.SObjectType);

    @AuraEnabled
    public static string startBatch(String jobType, Id schoolId, Id yearId)
    {
        try {
            String jobId;
            Integer batchSize = CommonConstants.DEFAULT_BATCHSIZE;

            switch on jobType {
                when 'CLASSES' {
                    jobId = ImportClassesBatch.run(batchSize, schoolId, yearId);
                }
                when 'STUDENTS' {
                    jobId = ImportStudentsBatch.run(batchSize, schoolId, yearId);
                }
                when 'PARENTS' {
                    jobId = ImportParentsBatch.run(batchSize, schoolId, yearId);
                }
                when else {
                    throw new AuraHandledException('jobType not valid');
                }
            }

            return jobId ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static JobStatus getJobStatus(String jobId){
        try {
            List<JobStatus> statusList = getJobStatus(new Set<Id>{jobId});
            if (statusList?.size() != 1)
            {
                throw new AuraHandledException(String.format('ERROR: Cannot find status information for given jobId', new List<Object>{jobId}));
            }
            return statusList[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<JobStatus> getJobStatus(Set<Id> jobIds){
        List<AsyncApexJob> jobInfo = [  SELECT Id, ApexClass.Name, Status, JobType, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset, CronTriggerId
                                        FROM AsyncApexJob
                                        WHERE Id IN :jobIds];
        List<JobStatus> statussesToReturn = new List<JobStatus>();
        for (AsyncApexJob currentJob : jobInfo)
        {
            statussesToReturn.add(new JobStatus(currentJob));
        }
        return statussesToReturn;
    }

    @AuraEnabled
    public static List<JobStatus> getSummary(Id classesJobId, Id parentsJobId, Id studentsJobId)
    {
        try 
        {
            return getJobStatus(new Set<Id>{classesJobId, parentsJobId, studentsJobId});
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/*
SELECT Id, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, ExtendedStatus, LastProcessedOffset FROM AsyncApexJob
WHERE Id IN ('7077Z00004AtEFO','7077Z00004AtEKb','7077Z00004AtEGY')
*/

    public class JobStatus 
    {
        @AuraEnabled
        public Integer steps;
        @AuraEnabled
        public Integer currentStep;
        @AuraEnabled
        public Integer numberOfErrors;
        @AuraEnabled
        public String statusMessage;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Datetime completedDate;
        @AuraEnabled
        public String name;

        public JobStatus(AsyncApexJob job)
        {
            this.steps = job.TotalJobItems;
            this.currentStep = job.JobItemsProcessed;
            this.statusMessage = job.ExtendedStatus;
            this.id = job.Id.to15();
            this.completedDate = job.CompletedDate;
            this.numberOfErrors = job.NumberOfErrors;
            this.name = job.ApexClass.Name;
            this.status = job.Status;
        }

    }

    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getSchoolYears()
    {
        try {
            List<SchoolYear__c> years = yearSelector.selectActive();
            return getOptionsFromObjects(years);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SelectOption> getSchools(){
        try {
            List<School__c> schools = schoolSelector.selectAll();
            return getOptionsFromObjects(schools);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static List<SelectOption> getOptionsFromObjects(List<Sobject> objects)
    {
        List<SelectOption> options = new List<SelectOption>();
        for (SObject currentObject : objects)
        {
            options.add(new SelectOption(currentObject));
        }
        return options;
    }

    public class SelectOption
	{
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;

		SelectOption(SObject currentObject)
		{
			this.label = (String)currentObject.get('Name');
			this.value = (String)currentObject.get('Id');
		}
	}
}