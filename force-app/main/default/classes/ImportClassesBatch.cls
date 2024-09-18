public class ImportClassesBatch implements Database.Batchable<SObject>
{
    private EducationService service;
    private Id schoolId;
    private Id schoolYearId;

	public ImportClassesBatch(Id school, Id schoolyear)
	{
			schoolId = school;
			schoolYearId = schoolyear;
	}

	public Database.QueryLocator start(Database.BatchableContext context)
	{
		ImportedStudentsSelector selector = (ImportedStudentsSelector) Application.Selector.newInstance(ImportedStudent__c.SObjectType);
		return selector.getQueryLocatorByImportStatusSchoolAndYear('New', schoolId, schoolyearId);
	}

	public void execute(Database.BatchableContext context, List<SObject> records)
	{
		if (this.service == null)
		{
			this.service = (EducationService) Application.Service.newInstance(EducationService.class);
		}

        Set<String> classes = new Set<String>();

        for (ImportedStudent__c student : (List<ImportedStudent__c>)records)
        {
            classes.add(student.Class_code__c);
        }

        service.createClasses(classes, schoolId, schoolYearId);
	}

	public void finish(Database.BatchableContext context)
	{

	}

	public static String run(Integer batchSize, Id schoolId, Id yearId)
	{
		ImportClassesBatch job = new ImportClassesBatch(schoolId, yearId);
		return Database.executeBatch(job, batchSize);
	}
}