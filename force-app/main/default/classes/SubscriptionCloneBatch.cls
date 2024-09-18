public class SubscriptionCloneBatch implements Database.Batchable<sObject>, Database.Stateful{
   public class MyException extends Exception{}

   private final String S7_LEVEL = 'S7';
    String cloneFromId;
    String cloneToId;
    String subscritpionType;
    Map<Id, String> errorMap;
    String schoolYear;
    Integer totalContacts;
    Integer ErrorContacts;
    Integer SuccessContacts;
    String startDate;
    String endDate;
    Map<String, String> schoolNameVsSchoolIdMap;
    SchoolYear__c nextSchoolYear;
    // Integer alreadySubscribedContacts;
    public SubscriptionCloneBatch(String cloneFromId, String cloneToId, String subscritpionType, String schoolYear, String startDate , String endDate) {
        this.cloneFromId = cloneFromId;
        this.cloneToId = cloneToId;
        this.subscritpionType = subscritpionType;
        this.schoolYear = schoolYear;
        this.errorMap = new Map<Id, String>();
        totalContacts = 0;
        ErrorContacts = 0;
        SuccessContacts = 0;
        this.startDate = startDate;
        this.endDate = endDate;
        this.schoolNameVsSchoolIdMap = new Map<String, String>();
     //   alreadySubscribedContacts = 0;
      //  system.debug(this.cloneFromId + ' --- ' + this.cloneToId + ' ---- ' + this.subscritpionType);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        for(School__c schl: [SELECT Id ,Name from School__c LIMIT 10000]) {
            schoolNameVsSchoolIdMap.put(schl.Name, schl.Id);
        }

        nextSchoolYear = [SELECT Id,Name, Startdate_trimester_1__c, Enddate_trimester_3__c FROM SchoolYear__c WHERE Id =: cloneToId LIMIT 1];

       
      return Database.getQueryLocator('SELECT Id FROM Contact');
    
    }
 
    public void execute(Database.BatchableContext BC, List<sObject> scope){
    
        Contact conRec = (Contact)scope[0];
        totalContacts ++ ;
        Boolean isSchool_P5_EVERE = false;
        if(subscritpionType == 'Bus Subscription') {
           try{

                List<BusSubscription__c> busSubscriptionList = new List<BusSubscription__c>();
                List<BusSubscription__c> busSubscriptionList2 = new List<BusSubscription__c>();
                String recId = conRec.Id;

                String busSubscriptionOld = getQuery('Bus Subscription');
                busSubscriptionOld += ' Id, School__r.Name FROM BusSubscription__c WHERE Student__c =: recId AND SchoolYear__c =: cloneFromId and Level__c !=: S7_LEVEL';
                String busSubscriptionNew = getQuery('Bus Subscription');
                busSubscriptionNew += ' Id, School__r.Name FROM BusSubscription__c WHERE Student__c =: recId AND SchoolYear__c =: cloneToId and Level__c !=: S7_LEVEL';

                busSubscriptionList = Database.query(busSubscriptionOld);
                busSubscriptionList2 =  Database.query(busSubscriptionNew);

                if(!busSubscriptionList.isEmpty() && !busSubscriptionList2.isEmpty() && (busSubscriptionList.size() == busSubscriptionList2.size() )){
                   // alreadySubscribedContacts ++;
                   SuccessContacts ++ ;
                }else if(busSubscriptionList.isEmpty() && busSubscriptionList2.isEmpty()){
                    SuccessContacts ++ ;
                }else if(!busSubscriptionList.isEmpty() && busSubscriptionList2.isEmpty()) {
                    List<ClassEnrollment__c> classEnrollToYearList = new List<ClassEnrollment__c>();
                    classEnrollToYearList = [Select School__c, Class_Type__r.Name,Class__r.Class__c , Class_Type__r.Language__c , Class_Type__r.Level__c FROM ClassEnrollment__c WHERE School_Year__c =: cloneToId And Status__c = 'Enrolled' AND Contact__c =: conRec.Id  LIMIT 1] ;
                     if(classEnrollToYearList.isEmpty()){
                        throw new MyException('Class Enrollment does not Exist for ' + this.schoolYear);
                     }
                    List<BusSubscription__c> busSubscriptionListToInsert = new List<BusSubscription__c>();
                    for(BusSubscription__c sub: busSubscriptionList) {
                        
                        BusSubscription__c newSub = sub.clone(false, false, false, false);
                        newSub.SchoolYear__c = cloneToId;
                       
                        if(sub.School__r.Name == 'Evere' && sub.Level__c == 'P5') {
                            isSchool_P5_EVERE = true;
                          
                        }
                        //  newSub.School__c = schoolNameVsSchoolIdMap.get('Woluwe');
                        newSub.School__c = schoolNameVsSchoolIdMap.get(classEnrollToYearList[0].School__c);
                        //  newSub.Level__c = 'S1';
                          newSub.Level__c = classEnrollToYearList[0].Class_Type__r.Level__c;

                        busSubscriptionListToInsert.add(newSub);
                    }

                    insert busSubscriptionListToInsert;
                    if(!isSchool_P5_EVERE){
                        Map<String, String> oldVsNewBusSubscriptionId = new Map<String, String>();
                    
                        Integer index = 0;
                        for(BusSubscription__c sub: busSubscriptionList) {
                            oldVsNewBusSubscriptionId.put(sub.Id, busSubscriptionListToInsert[index].Id);
                            index ++;
                        }

                        List<Busride__c> busRideList = new List<Busride__c>();
                        Set<String> Ids = oldVsNewBusSubscriptionId.keyset();
                        String busRideQuery = getQuery('Bus Rides');
                        busRideQuery += ' Id From Busride__c WHERE Subscription__c IN: Ids  AND Status__c = \'Approved\'';
                        //busRideList = [SELECT ID, Student__c, Subscription__c, Route__c, Busstop__c, Ridetype__c, Startdate__c, Status__c, Authorization__c, Departure_time__c, Time__c From Busride__c WHERE Subscription__c IN: oldVsNewBusSubscriptionId.keyset() AND Status__c = 'Approved'];
                        busRideList = Database.query(busRideQuery);
                        if(!busRideList.isEmpty()) {
                            List<Busride__c> busRideListToInsert = new List<Busride__c>();
                            for(Busride__c sub: busRideList) {
                                Busride__c newSub = sub.clone(false, false, false, false);
                                newSub.Subscription__c = oldVsNewBusSubscriptionId.get(sub.Subscription__c);
                                newSub.Startdate__c = nextSchoolYear.Startdate_trimester_1__c;
                                newSub.Enddate__c = nextSchoolYear.Enddate_trimester_3__c;
                                busRideListToInsert.add(newSub);
                            }

                            insert busRideListToInsert;
                            
                        }
                    }
                    SuccessContacts ++ ;
                }
            } catch (Exception ex) {
                system.debug(ex.getMessage());
                errorMap.put(conRec.Id, ex.getMessage());
                ErrorContacts ++ ;
                }
           
        } else if(subscritpionType == 'Canteen Subscription') {
            try{
                String recId = conRec.Id;
              //  List<SchoolYear__c> schoolYearList = [SELECT Id,Name, Startdate_trimester_1__c, Enddate_trimester_3__c FROM SchoolYear__c WHERE Id =: cloneToId LIMIT 1];
                List<CanteenSubscription__c> canteenSubscriptionList = new List<CanteenSubscription__c>();
                List<CanteenSubscription__c> canteenSubscriptionList2 = new List<CanteenSubscription__c>();
                 String canteenSubscriptionOld = getQuery('Canteen Subscription');
                 canteenSubscriptionOld += ' Id FROM CanteenSubscription__c WHERE Student__c =: recId AND SchoolYear__c =: cloneFromId AND Status__c = \'Approved\' AND NrOfDaysRequested__c >= 3';
                 String canteenSubscriptionNew = getQuery('Canteen Subscription');
                 canteenSubscriptionNew += ' Id FROM CanteenSubscription__c WHERE Student__c =: recId AND SchoolYear__c =: cloneToId AND Status__c = \'Approved\' AND NrOfDaysRequested__c >= 3';
               
                 canteenSubscriptionList = Database.query(canteenSubscriptionOld);
                 canteenSubscriptionList2 =  Database.query(canteenSubscriptionNew);

                 if(!canteenSubscriptionList.isEmpty() && !canteenSubscriptionList2.isEmpty() && (canteenSubscriptionList.size() == canteenSubscriptionList2.size() )){
                    // alreadySubscribedContacts ++;
                    SuccessContacts ++ ;
                 }else if(canteenSubscriptionList.isEmpty() && canteenSubscriptionList2.isEmpty()){
                     SuccessContacts ++ ;
                 }else if(!canteenSubscriptionList.isEmpty() && canteenSubscriptionList2.isEmpty()) {
                    List<School__c> schList = new List<School__c>();
                    // school will always to 'Woluwe'
                    
                   //   schList = [SELECT Id, Name FROM School__c WHERE Name = 'Woluwe' LIMIT 1];
                    List<ClassEnrollment__c> classEnrollToYearList = new List<ClassEnrollment__c>();
                    classEnrollToYearList = [Select Class_Type__r.Name,Class__r.Class__c , Class_Type__r.Language__c FROM ClassEnrollment__c WHERE School_Year__c =: cloneToId And Status__c = 'Enrolled' AND Contact__c =: conRec.Id  LIMIT 1] ;
                     if(classEnrollToYearList.isEmpty()){
                        throw new MyException('Class Enrollment does not Exist for ' + this.schoolYear);
                     }
                    List<CanteenSubscription__c> canteenSubscriptionListToInsert = new List<CanteenSubscription__c>();
                     for(CanteenSubscription__c sub: canteenSubscriptionList) {
                        CanteenSubscription__c newSub = sub.clone(false, false, false, false);
                         newSub.SchoolYear__c = cloneToId;
                         newSub.Enrollment__c = classEnrollToYearList[0].Id;
                        newSub.Class_Type__c = classEnrollToYearList[0].Class_Type__r.Name;
                        newSub.Class__c = classEnrollToYearList[0].Class__r.Class__c;
                        newSub.Language__c = classEnrollToYearList[0].Class_Type__r.Language__c;
                        newSub.Startdate__c = Date.valueOf(startDate);
                        newSub.Enddate__c = Date.valueOf(endDate);
                     //    newSub.School__c = ''
                     canteenSubscriptionListToInsert.add(newSub);
                     }
 
                     insert canteenSubscriptionListToInsert;
 
                    
                         SuccessContacts ++ ;
                }
            } catch(Exception ex){
                system.debug(ex.getMessage());
                errorMap.put(conRec.Id, ex.getMessage());
                ErrorContacts ++ ;
            }
        }
    }    
    
 
    public void finish(Database.BatchableContext BC){

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply@woluweparents.org'];
        
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        String body = 'Hi, <br/><br> There are total ' + totalContacts + ' Contact out of which ' + SuccessContacts + ' contact has successfully cloned' ; 
        // if(alreadySubscribedContacts != 0){
        //     body += ' and ' + alreadySubscribedContacts + ' contacts has already subscribed';
        // }
        if(errorMap != null && errorMap.keyset() != null && errorMap.size() > 0) {
            String errorData = '';
            errorData += 'Contact Id, Error Message \n'; 
            for(String str: errorMap.keyset()) {
                errorData += str + ',' + errorMap.get(str) + '\n';
            }


            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S'; //denotes it resides on Salesforce
            cv.Title = subscritpionType + ' for ' + schoolYear  + ' Error File'; //title of the file
            cv.PathOnClient =  subscritpionType + ' for ' + schoolYear + ' Error File.csv'; // full path within Salesforce this can just be the name of file to be in the library
            cv.VersionData = Blob.valueOf(errorData);

            insert cv;

            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = cloneToId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;

            body += ' and ' + ErrorContacts + ' Contacts has error. Please Find below attached Error file';
            // Define email file attachment list
            Messaging.EmailFileAttachment[] emailAttList = new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(subscritpionType + ' for ' + schoolYear + ' Error File.csv');
            efa.setBody(Blob.valueOf(errorData));
            emailAttList.add(efa);

            
            email.setFileAttachments(emailAttList);
           
            
        }

        body += '.<br/><br/> Thanks';
        email.setSubject( subscritpionType + ' Cloning for ' + schoolYear);
       List<String> toAddresses = new List<String>{userInfo.getUserEmail()};
     
        email.setToAddresses( toAddresses);
        
       // email.setPlainTextBody( body );
        email.setHtmlBody( body );

        // Sends the email
        Messaging.SendEmailResult [] r =
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

    }

    private List<Schema.FieldSetMember> getFields(String actionName) {
        List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>();
       if(actionName == 'Bus Subscription'){
        fieldSetMemberList = SObjectType.BusSubscription__c.FieldSets.BusSubscriptionCloning.getFields();
       }else if(actionName == 'Bus Rides'){
        fieldSetMemberList = SObjectType.Busride__c.FieldSets.BusRidesCloneSubscriptions.getFields();
       }
       else if(actionName == 'Canteen Subscription'){
       fieldSetMemberList = SObjectType.CanteenSubscription__c.FieldSets.CanteenSubscriptionClone.getFields();
       }
       return fieldSetMemberList;
    }

    private String getQuery(String actionName) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : getFields(actionName)) {
            query += f.getFieldPath() + ', ';
        }
       // query += 'Id FROM BusSubscription__c';
        return query;
    }
}