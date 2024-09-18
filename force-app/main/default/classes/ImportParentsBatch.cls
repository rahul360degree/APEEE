public class ImportParentsBatch implements Database.Batchable<SObject>
{
	private ImportsService service;
	private Id schoolId;
	private Id schoolYearId;


	public ImportParentsBatch(Id school, Id schoolyear)
	{
		schoolId = school;
		schoolYearId = schoolyear;
	}

	private ImportParentsBatch(ImportsService service) 
	{
		this.service = service;
	}

	public Database.QueryLocator start(Database.BatchableContext context)
	{
		ImportedParentsSelector selector = (ImportedParentsSelector) Application.Selector.newInstance(ImportedParent__c.SObjectType);
		return selector.getQueryLocatorByImportStatusSchoolAndYear('New', schoolId, schoolYearId);
	}

	public void execute(Database.BatchableContext context, List<SObject> records)
	{
		if (this.service == null)
		{
			this.service = (ImportsService) Application.Service.newInstance(ImportsService.class);
		}

		service.processParents((List<ImportedParent__c>) records);
	}

	public void finish(Database.BatchableContext context)
	{
	}

	public static String run(Integer batchSize, Id school, Id schoolyear)
	{
		ImportParentsBatch job = new ImportParentsBatch(school, schoolyear);
		return Database.executeBatch(job, batchSize);
	}
}