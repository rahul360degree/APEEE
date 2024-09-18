@isTest
public class SobjectUpsertUtilityTest {
	@isTest
    public static void upsertObjectTest(){
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'test';
        accList.add(acc);
        try{
            Test.startTest();
            SobjectUpsertUtility.upsertObject(accList);
            Test.stopTest();
        }Catch(Exception e){
            
        }
        
    }
    
    @isTest
    public static void upsertObjectTest2(){
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'test';
        acc.ShippingCity = 'test city';
        acc.ShippingCountry = 'test country';
        acc.ShippingPostalCode = 'test postal code';
        acc.ShippingStreet = 'test street';
        
        accList.add(acc);
        try{
            Test.startTest();
            SobjectUpsertUtility.upsertObject(accList);
            Test.stopTest();
        }Catch(Exception e){
            
        }
        
    }
}