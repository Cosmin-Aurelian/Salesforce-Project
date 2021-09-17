public with sharing class SendEmailWithTemplate {
    public static void sendEmail(String emailTemplateName, Id contactId, Id relatedObjectId)
    {
        if(String.isBlank(emailTemplateName) || contactId == NULL || relatedObjectId == NULL) return; // punem un fel de limitare care sa nu crape

        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();

        EmailTemplate emailTemplateParam;
        for(EmailTemplate emailIterator : [SELECT Id, Subject, Body FROM EmailTemplate WHERE Developername =: emailTemplateName]) //aici pun emailTemplate-ul/ avem parametrul EmailTemplate / de retinut =: se foloseste la final de querry si se numeste binding
        {
            emailTemplateParam= emailIterator;
        }
        if(emailTemplateParam == NULL) return;

        List<String> toAddresses = new List<String>();
        for (Contact contact: [SELECT Email FROM Contact WHERE Id =: contactId])
        {
            toAddresses.add(contact.Email);
        }
        //System.debug(contact.email);
        //system.debug(contactid);
        //System.debug(toAddress.email);

        if(toAddresses.isEmpty() == TRUE)return; // sa nu crape

        try{
            emailMessage.setTargetObjectId(contactId); //id-ul contactului /am pus ca parametru contactId
            //Required if using a template, optional otherwise. The ID of the contact, lead, or user to which the email will be sent.
            //The ID you specify sets the context and ensures that merge fields in the template contain the correct data.
            emailMessage.setTemplateId(emailTemplateParam.Id);
            //Required if using a template, optional otherwise. The ID of the template used to create the email.
            emailMessage.setToAddresses(toAddresses);
            /*Optional. A list of email addresses or object IDs of the contacts, leads, and users you’re sending the email to.
             The maximum size for this field is 4,000 bytes. The maximum total of toAddresses, ccAddresses, and bccAddresses per email is 150.
              All recipients in these three fields count against the limit for email sent using Apex or the API.*/

            emailMessage.setWhatId(relatedObjectId); // id-ul apartamentului / am pus ca parametru relatedObjectId
            //If you specify a contact for the targetObjectId field, you can specify an optional whatId as well. 
            //This helps to further ensure that merge fields in the template contain the correct data.
            Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailMessage});
        } catch(Exception e){
            System.debug(e.getMessage());
        }
    
    }

    
}
