public without sharing class Utils 
{

	public static String getUniqueAddressKey(ImportedParent__c parent)
	{
		return constructAddressKey(
				parent.City__c,
				parent.Postalcode__c,
				parent.Street__c,
				CommonConstants.addressKeysByRecordType.get(CommonConstants.HOUSEHOLD_RECORDTYPE)
		);
	}

	public static String getUniqueAddressKey(Account theAccount)
	{
		if (theAccount.RecordTypeId == CommonConstants.HOUSEHOLD_RECORDTYPE)
		{
			return constructAddressKey(
					theAccount.ShippingCity,
					theAccount.ShippingPostalCode,
					theAccount.ShippingStreet,
					CommonConstants.addressKeysByRecordType.get(theAccount.RecordTypeId)
			);
		}
		return null;
	}

	private static String constructAddressKey(String city, String postalcode, String street, String postfix)
	{
		String addressString = city + postalcode + street + postfix;
		return addressString.deleteWhitespace().toUpperCase();
	}

	public static String getNormalizedGender(String genderValue)
	{
		if (CommonConstants.genderMapping.containsKey(genderValue))
		{
			return CommonConstants.genderMapping.get(genderValue);
		}
		return null;
	}

	public static String getNormalizedRelation(String relationValue)
	{
		String strippedValue = relationValue?.replaceAll('[^a-zA-Z0-9]', '').toLowercase();
		if (CommonConstants.relationMapping.containsKey(strippedValue))
		{
			return CommonConstants.relationMapping.get(strippedValue);
		}
		return null;
	}
	
	public static String getLanguageFromCode(String code)
	{
		return CommonConstants.LANGUAGES_BY_CODE.get(code);
	}

}