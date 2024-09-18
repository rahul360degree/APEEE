public without sharing class Accounts extends fflib_SObjectDomain
{
	// Added default constructor to disable CRUD security check. Otherwise account creation through the portal is not possible.	
	public Accounts(List<SObject> records) {
		super(records);
		Configuration.disableTriggerCRUDSecurity();
	}

	private final Set<String> ADDRESS_FIELDS = new Set<String>{'ShippingStreet', 'ShippingCity', 'ShippingCountry', 'ShippingPostalCode'};

	public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
	{
		List<Account> accountsToUpdateAddressKey = getChangedRecords(ADDRESS_FIELDS);
		setAddressKey(accountsToUpdateAddressKey);
	}

	public override void onBeforeInsert()
	{
		setAddressKey((List<Account>) Records);
	}

	private void setAddressKey(List<Account> accounts)
	{
		for (Account currentAccount : accounts)
		{
			currentAccount.UniqueAddressKey__c = Utils.getUniqueAddressKey(currentAccount);
		}
	}

	public Accounts(List<Account> sObjectList)
	{
		super(sObjectList);
	}

	public Accounts(List<Account> records, Schema.SObjectType sObjectType)
	{
		super(records, sObjectType);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2{

		public fflib_SObjectDomain construct(List<SObject> sObjectList){
			return new Accounts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType){
			return new Accounts(sObjectList, sObjectType);
		}
	}
}