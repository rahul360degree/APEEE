public class ContactsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Contact.Id,
				Contact.AccountId,
				Contact.Card_ID__c,
				Contact.School_Contact_ID__c,
				Contact.Email,
				Contact.FirstName,
				Contact.IBAN__c,
				Contact.LastName,
				Contact.Second_Email__c,
				Contact.MobilePhone,
				Contact.HomePhone,
				Contact.Phone,
				Contact.MailingCountry
			};
	}

	// Returns a map with contacts by their key values (mailaddress AND apeeeId if applicable)
	public Map<String, Contact> selectByKeyValues(Set<String> idSet, Set<String> emailAddresses, Id recordTypeId)
	{
		String ENROLLMENT_STATUS = 'Enrolled';

		Map<String, Contact> contactsByApeeeId = new Map<String, Contact>();

		fflib_QueryFactory queryfactory = newQueryFactory()
			.selectField('Account.UniqueAddressKey__c')
			.setCondition('(School_Contact_ID__c IN :idSet OR Email IN :emailAddresses) AND RecordTypeId = :recordTypeId');
		
		System.debug('query :' + queryfactory.toSOQL());

		fflib_QueryFactory enrollmentsFactory = queryfactory
			.subSelectQuery('Class_Enrollments__r')
			.selectFields(new ClassEnrollmentsSelector().getSObjectFieldList())
			.selectField('Class_Type__r.School__c')
			.setCondition('Status__c = :ENROLLMENT_STATUS AND (Enroll_End_Date__c > TODAY OR Enroll_End_Date__c = NULL)');

		for (Contact currentContact : Database.query(queryfactory.toSOQL()))
		{
			if (null != currentContact.School_Contact_ID__c)
			{
				contactsByApeeeId.put(currentContact.School_Contact_ID__c, currentContact);
			}
			if (null != currentContact.Email) {
				contactsByApeeeId.put(currentContact.Email, currentContact);
			}
		}

		return contactsByApeeeId;
	}

	public Schema.SObjectType getSObjectType()
	{
		return Contact.sObjectType;
	}

	public List<Contact> selectById(Set<ID> idSet)
	{
		return (List<Contact>) selectSObjectsById(idSet);
	}

}