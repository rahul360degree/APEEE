public class ImportedStudentsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			ImportedStudent__c.Id,
			ImportedStudent__c.Name,
			ImportedStudent__c.Card_ID__c,
			ImportedStudent__c.Student_ID__c,
			ImportedStudent__c.Class_code__c,
			ImportedStudent__c.Surname__c,
			ImportedStudent__c.Firstname__c,
			ImportedStudent__c.Birthdate__c,
			ImportedStudent__c.Gender__c,
			ImportedStudent__c.Enrolment_Date__c,
			ImportedStudent__c.Email__c,
			ImportedStudent__c.School__c,
			ImportedStudent__c.School_Year__c,
			ImportedStudent__c.Import_status__c,
			ImportedStudent__c.PerNum__c ,
			ImportedStudent__c.Contact__c
			};
	}

	public Database.QueryLocator getQueryLocatorByImportStatusSchoolAndYear(String status, Id schoolId, Id schoolyearId)
	{
		fflib_QueryFactory queryfactory = newQueryFactory()
			.selectField('School__r.Name')
			.setCondition('Import_status__c = :status AND School__c = :schoolId AND School_Year__c = :schoolyearId');
		return Database.getQueryLocator(queryfactory.toSOQL());
	}

	public Schema.SObjectType getSObjectType()
	{
		return ImportedStudent__c.sObjectType;
	}

	public List<ImportedStudent__c> selectById(Set<ID> idSet)
	{
		return (List<ImportedStudent__c>) selectSObjectsById(idSet);
	}

}