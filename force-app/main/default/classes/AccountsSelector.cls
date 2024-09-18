public class AccountsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Account.Id,
				Account.ShippingCity,
				Account.ShippingPostalCode,
				Account.ShippingStreet,
				Account.UniqueAddressKey__c
			};
	}

	public Map<String, Account> selectByAddressKeyAndRecordtype(Set<String> keys, Id recordType)
	{
		Map<String, Account> accountsByKey = new Map<String, Account>();

		fflib_QueryFactory queryfactory = newQueryFactory()
			.setCondition('UniqueAddressKey__c IN : keys AND recordTypeId = :recordType');
		for (Account currentAccount : Database.query(queryfactory.toSOQL()))
		{
			accountsByKey.put(currentAccount.UniqueAddressKey__c, currentAccount);
		}

		return accountsByKey;
	}

	public Schema.SObjectType getSObjectType()
	{
		return Account.sObjectType;
	}

	public List<Account> selectById(Set<ID> idSet)
	{
		return (List<Account>) selectSObjectsById(idSet);
	}

}