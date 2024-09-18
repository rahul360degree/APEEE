@isTest
public class RelatedListControllerTest {
    @testsetup
    public static void setupData(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.ShippingCity = 'test city';
        acc.ShippingCountry = 'test country';
        acc.ShippingPostalCode = 'test postal code';
        acc.ShippingStreet = 'test street';
        insert acc;
        Contact con = new Contact();
        con.lastname = 'test';
        con.AccountId = acc.Id;
        insert con;
    }
    @isTest
    public static void fetchDataTest(){
        Account acc = [Select Id from Account LIMIT 1];
        Test.startTest();
        	RelatedListController.fetchData('Name','Contact',acc.Id,'accountId','accountId != null');
        Test.stopTest();
    }
     @isTest
    public static void fetchDataTest1(){
        Account acc = [Select Id from Account LIMIT 1];
        Test.startTest();
        	RelatedListController.fetchData('Name','Contact','','','accountId != null');
        Test.stopTest();
    }
}