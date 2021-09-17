public without sharing class NewCaseFormController {
    
    @AuraEnabled
    public static String insertCase(String recordType, String emailParam, String description, String subject, String priority, String typeReason, String accountId, Decimal amount, String documentIdParameter){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();

        Id parentId;
        for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Id =: accountId ]) {
            parentId = c.AccountId;
        }
    
        if(parentId == NULL) throw new AuraHandledException('No parent id found');
        Apartment__c apartment = [SELECT Id FROM Apartment__c WHERE AccountName__c =: parentId ];
        
        Case newCase = new Case(
            Status= 'New',
            Description = description,
            recordTypeId = recordTypeId,
            SuppliedEmail = emailParam, 
            Origin = 'web',
            Subject = subject,
            Priority = priority,
            Reason = typeReason,
            Apartment__c = apartment.Id,
            Estimated_Amount__c = amount
        );
        insert newCase;
        if(String.isNotBlank(documentIdParameter)){
            ContentDocumentLink currentDocLink = new ContentDocumentLink();
            currentDocLink.LinkedEntityId = newCase.id;
            currentDocLink.contentDocumentId = documentIdParameter;
            
            insert currentDocLink;
        }
        return newCase.Id;
    }


    @AuraEnabled
    public static Map<String,String> getPickListValuesByRecordTypeId(string recordTypeParameter) {   
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeParameter).getRecordTypeId();
        Httprequest req = new HttpRequest();
        
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v50.0/ui-api/object-info/Case/picklist-values/' + recordTypeId + '/Reason');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        Map<String, Object> respBodyMap = (Map<String, Object>) Json.deserializeUntyped(res.getBody());
        List<object> valuesObjList = (List<object>) respBodyMap.get('values');
    
        Map<String,String> activeEntries = new Map<String,String>();
        for (object obj : valuesObjList) {
            Map<string, object> valuesMap = (map<string, object>) obj;
            activeEntries.put((string) valuesMap.get('label'),(string) valuesMap.get('value'));
        }
        return activeEntries;
    }

    @AuraEnabled
    public static void sendEmail(String emailTemplateName, Id contactId, Id relatedObjectId){
         
        if (emailTemplateName == NULL || contactId == NULL || relatedObjectId == NULL){return;}
 
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        EmailTemplate emailTemplate;
        for (EmailTemplate email: [SELECT Id FROM EmailTemplate WHERE DeveloperName =: emailTemplateName]){
            emailTemplate = email;
        }
 
        if (emailTemplate == NULL){return;}
 
        List<String> toAddresses = new List<string>();
        for (Contact contact: [SELECT Id, Email FROM Contact WHERE Id=: contactId]){
            toAddresses.add(contact.Email);
        }
 
        if (toAddresses.isEmpty()) return;
        try{
            emailMessage.setTargetObjectId(contactId);
            emailMessage.setTemplateId(emailTemplate.id);
            emailMessage.setWhatId(relatedObjectId);
            emailMessage.setToAddresses(toAddresses);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[] {emailMessage});
        }catch (Exception e){
            System.debug(e.getMessage());
        }   
    }  
}
