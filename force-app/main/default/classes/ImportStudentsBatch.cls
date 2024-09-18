public class ImportStudentsBatch implements Database.Batchable<SObject>
{
	private ImportsService service;
	private Id schoolId;
	private Id schoolyearId;


	public ImportStudentsBatch(Id school, Id schoolyear)	
	{
		this.schoolId = school;
		this.schoolyearId = schoolyear;
	}

	private ImportStudentsBatch(ImportsService service, ImportedStudentsSelector selector) 
	{
		this.service = service;
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
			this.service = (ImportsService) Application.Service.newInstance(ImportsService.class);
		}
		service.processStudents((List<ImportedStudent__c>) records);
	}

	public void finish(Database.BatchableContext context)
	{

	}

	public static String run(Integer batchSize, Id school, Id schoolyear)
	{
		ImportStudentsBatch job = new ImportStudentsBatch(school, schoolyear);
		return Database.executeBatch(job, batchSize);
	}

	/**
	 * -> Enrollments
	: School year  | Kan al bestaan
	: Class Type   |
	: Class


Clas_code__c -> Class
 --> Classtype - laatste letter

Als Class nog niet bestaat:

 --> Aanmaken voor School/Schooljaar/ClassType
	 */

	 /*

List<ImportedParent__c> parents = [SELECT Id, Import_Status__c FROM ImportedParent__c];

for (ImportedParent__c p : parents)
{
	p.Import_Status__c = 'New';
}

update parents;

delete [SELECT Id FROM Contact];
delete [SELECT Id FROM Account];

*/

/*
ImportStudentsBatch.run(100);

List<AggregateResult> types = [SELECT COUNT(Id), Name FROM ClassType__c GROUP BY NAME HAVING COUNT(Id) > 1];
Set<String> duplicates = new Set<String>();

for (AggregateResult ar: types)
{
	duplicates.add((String)ar.get('Name'));    
}

List<ClassType__c> typestoCheck = [SELECT Id, Name FROM ClassType__c WHERE Name IN :duplicates ORDER BY CreatedDate asc];

Set<String> handled = new Set<String>();
List<ClassType__c> toDelete = new List<ClassType__c>();

for (ClassType__c current : typestoCheck)
{
    if (handled.contains(current.Name))
    {
        toDelete.add(current);
    }
    else
    {
        handled.add(current.Name);
    }
}


delete toDelete;
*/

//ImportParentsBatch.run(1000);
}