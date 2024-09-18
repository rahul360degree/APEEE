public class ImportedParentsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				ImportedParent__c.Id,
				ImportedParent__c.City__c,
				ImportedParent__c.Class_code__c,
				ImportedParent__c.Contact__c,
				ImportedParent__c.Email__c,
				ImportedParent__c.Firstname__c,
				ImportedParent__c.IBAN__c,
				ImportedParent__c.ImportedStudent__c,
				ImportedParent__c.Import_status__c,
				ImportedParent__c.Main_contact__c,
				ImportedParent__c.Name,
				ImportedParent__c.Parent_Id__c,
				ImportedParent__c.Payer__c,
				ImportedParent__c.Postalcode__c,
				ImportedParent__c.Relationship__c,
				ImportedParent__c.School_Year__c,
				ImportedParent__c.School__c,
				ImportedParent__c.Street__c,
				ImportedParent__c.Student_ID__c,
				ImportedParent__c.Surname__c,
				ImportedParent__c.Second_email__c,
				ImportedParent__c.Mobile__c,
				ImportedParent__c.Home_Phone__c,
				ImportedParent__c.Work_Phone__c,
				ImportedParent__c.Country__c
			};
	}

	public Database.QueryLocator getQueryLocatorByImportStatusSchoolAndYear(String status, Id schoolId, Id schoolyearId)
	{
		fflib_QueryFactory queryfactory = newQueryFactory()
			.setCondition('Import_status__c = :status AND School__c = :schoolId AND School_Year__c = :schoolyearId');
		return Database.getQueryLocator(queryfactory.toSOQL());
	}

	public List<ImportedParent__c> getByExternalStudentId(Set<String> studentIds)
	{
		fflib_QueryFactory queryfactory = newQueryFactory()
			.selectField('Contact__r.AccountId')
			.setCondition('Student_ID__c IN :studentIds');

		return Database.query(queryfactory.toSOQL());
	}

	public Schema.SObjectType getSObjectType()
	{
		return ImportedParent__c.sObjectType;
	}

	public List<ImportedParent__c> selectById(Set<ID> idSet)
	{
		return (List<ImportedParent__c>) selectSObjectsById(idSet);
	}

}