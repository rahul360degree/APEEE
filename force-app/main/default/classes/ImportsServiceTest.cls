@isTest
public class ImportsServiceTest 
{
    private static fflib_ISObjectUnitOfWork getUowMock()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISobjectUnitOfWork.class);
        return uowMock;
    }

    @IsTest
    static void itShouldImportStudents(){
        ImportsService service = new ImportsService(getUowMock());

        Test.startTest();
        service.processStudents(new List<ImportedStudent__c>{new ImportedStudent__c()});
        Test.stopTest();
        
    }

    @IsTest
    static void itShouldImportParents(){
        ImportsService service = new ImportsService(getUowMock());

        Test.startTest();
        service.processParents(new List<ImportedParent__c>{new ImportedParent__c()});
        Test.stopTest();
    }
}