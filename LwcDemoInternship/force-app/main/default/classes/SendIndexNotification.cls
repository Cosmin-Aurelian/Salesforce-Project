public with sharing class SendIndexNotification {
   
    public  static void SendIndexNotification() {
        String TemplateName = 'Index_Due_Date';
        Date currentDate = Date.today();
        integer currentMonth = currentDate.month();
        List<Index__c> indexSubmitted = new List<Index__c>();
        indexSubmitted = [SELECT Id FROM Index__c WHERE CALENDAR_MONTH(Date_Added__c) =: currentMonth];
        List<Index__c> apartamentsWithIndexList = new List <Index__c>([SELECT Id, Apartment__c FROM Index__c WHERE Id =: indexSubmitted]);
        List<Apartment__c> apartamentsWithSubmittedIndex = new List<Apartment__c>([SELECT AccountName__c FROM Apartment__c WHERE Id NOT IN ( SELECT Apartment__c FROM Index__c WHERE Id =: indexSubmitted)]);
        
        System.debug(apartamentsWithSubmittedIndex);
        List<Id> idList = new List<Id>();
        for(Apartment__c ap: apartamentsWithSubmittedIndex)
        {
            idList.add(ap.AccountName__c);
        }
        
        System.debug(idList);
        List<Contact> contacts = new List<Contact>([SELECT Id FROM Contact WHERE AccountId IN: idList]);
        System.debug(contacts);
        for(Contact contactIdEmail : contacts){
            SendEmailWithTemplate.sendEmail(TemplateName, contactIdEmail.Id, 'a000900000CD0HpAAL');
            //SendEmail.sendEmail('Payment_Due_Template', '0030900000Rq0MUAAZ', 'a000900000Dc6dgAAB');
        }
    }
}