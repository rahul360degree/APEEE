@isTest
public class AccountTriggerTest 
{
    // Not an actual test.. needed to be able to deploy trigger
    @IsTest
    static void createTriggerCoverage(){
        
        Test.startTest();
        Account t = new Account(Name = 'testAccount', RecordTypeId = CommonConstants.HOUSEHOLD_RECORDTYPE, ShippingStreet = 'street', ShippingCity = 'city', ShippingCountry = 'country', ShippingPostalCode = 'code');

        insert t;
        Test.stopTest();
        
        Account result = [SELECT UniqueAddressKey__c FROM Account WHERE Id = :t.Id LIMIT 1];
        system.assertEquals('CITYCODESTREETH', result.UniqueAddressKey__c);
    }
}