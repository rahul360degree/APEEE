public class TestClassApex {
    
    public static void test1() {
        List<Busride__c> bsList = [SELECT ID, Student__r.AccountId, Parent__c FROM Busride__c LIMIT 5];
        Set<Id> accIds = new Set<Id>();
        
        for(Busride__c bs: bsList ) {
            system.debug(bs.Id);
            accIds.add(bs.Student__r.AccountId);
        }
        
        Map<String, List<AccountContactRelation>> accIdVsAcrListMap = new Map<String, List<AccountContactRelation>>();
        
        for(AccountContactRelation acr: [SELECT ID, AccountId, ContactId, Relation__c FROM AccountContactRelation WHERE AccountId IN: accIds]) {
            if(!accIdVsAcrListMap.containsKey(acr.AccountId)) {
                accIdVsAcrListMap.put(acr.AccountId, new List<AccountContactRelation>{});
            }
            accIdVsAcrListMap.get(acr.AccountId).add(acr);
        }
        
        System.debug(accIdVsAcrListMap);
        
        for(Busride__c bs: bsList ) {
            AccountContactRelation father;
            AccountContactRelation mother;
            AccountContactRelation stepFather;
            AccountContactRelation stepMother;
            if(accIdVsAcrListMap.get(bs.Student__r.AccountId) != null){
                for(AccountContactRelation acr: accIdVsAcrListMap.get(bs.Student__r.AccountId)) {
                if(acr.Relation__c == 'Father') {
                    father = acr;
                } else if(acr.Relation__c == 'Mother') {
                    mother = acr;
                } else if(acr.Relation__c == 'StepFather') {
                    stepFather = acr;
                } else if(acr.Relation__c == 'StepMother') {
                    stepMother = acr;
                }
            }
            }
            
            
            System.debug(father);
            System.debug(mother);
            
            if((father != null && bs.Parent__c == father.ContactId) || (stepFather != null && bs.Parent__c == stepFather.ContactId)) {
                if(mother != null) {
                    System.debug('Inside Mother');
                    bs.SecondParent__c = mother.ContactId;
                } else if(stepMother != null) {
                    bs.SecondParent__c = stepMother.ContactId;
                }
            } else if((mother != null && bs.Parent__c == mother.ContactId) || (stepMother != null && bs.Parent__c == stepMother.ContactId)) {
                if(father != null) {
                    bs.SecondParent__c = father.ContactId;
                } else if(stepFather != null) {
                    bs.SecondParent__c = stepFather.ContactId;
                }
            }
        }
        
        update bsList;
        
    }
}