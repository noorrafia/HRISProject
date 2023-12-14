public class BatchToGetSlot implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id, Slot__c, date__c, Time__c
            FROM Interview_Dates__mdt
        ]);
    }
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        Map<String, List<Contact>> slotToContactsMap = new Map<String, List<Contact>>();
        // Populate the map with an empty list for each slot
        for (Interview_Dates__mdt slot : (List<Interview_Dates__mdt>) scope) {
            slotToContactsMap.put(String.valueOf(slot.Slot__c), new List<Contact>());
        }
        // Query Contacts with non-null Allocated_Slot__c
        List<Contact> contacts = [
            SELECT Id, FirstName,Email,Name, LastName, Allocated_Slot__c,Position__c
            FROM Contact
            WHERE Allocated_Slot__c !=null];
        // Populate the map with contacts based on their allocated slots
        for (Contact contact : contacts) {
            String allocatedSlot = String.valueOf(contact.Allocated_Slot__c);
            if (slotToContactsMap.containsKey(allocatedSlot)) {
                slotToContactsMap.get(allocatedSlot).add(contact);
            }
        }
        // Access metadata records for each slot dynamically
        for (String slotNumber : slotToContactsMap.keySet()) {
            List<Contact> slotContacts = slotToContactsMap.get(slotNumber);
            System.debug('Contacts for Slot ' + slotNumber + ': ' + slotContacts.size());
            // Process metadata records for the current slot
            List<Interview_Dates__mdt> slotMetadataRecords = new List<Interview_Dates__mdt>();
            for (SObject metadataRecord : scope) {
                Interview_Dates__mdt slotMetadata = (Interview_Dates__mdt)metadataRecord;
                if (String.valueOf(slotMetadata.Slot__c) == slotNumber) {
                    slotMetadataRecords.add(slotMetadata);
                }
            }
            // Process metadata records for the current slot and send emails
            sendEmails(slotContacts, slotMetadataRecords);
        }
    }
    public void finish(Database.BatchableContext context) {
        // Implement any cleanup logic
    }
    public void sendEmails(List<Contact> contacts, List<Interview_Dates__mdt> metadataRecords) {
        system.debug('Inside the mail method');
        
        EmailTemplate emailTemplateInvitation = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                 FROM EmailTemplate
                                                 WHERE DeveloperName ='Invitation_for_an_Interview'];
        
        OrgWideEmailAddress orgEmailID = [SELECT Id, DisplayName FROM OrgWideEmailAddress Where DisplayName  = 'RaagviTech'];
        
        String  htmlBodyInvitation = emailTemplateInvitation.HtmlValue;
        String subjectInvitation = emailTemplateInvitation.Subject;
        For(Interview_Dates__mdt mdtdata :metadataRecords){
            String dateT =String.valueOf(mdtdata.Date__c);
            htmlBodyInvitation = htmlBodyInvitation.replace('{!CustomDate}',dateT);
            htmlBodyInvitation = htmlBodyInvitation.replace('{!CustomTime}',mdtdata.Time__c);
        }
        system.debug('htmlBodyInvitation'+htmlBodyInvitation);
       // system.debug('htmlBodyInvitation>>'+htmlBodyInvitation);
        
        //AllocatedSlotList__mdt cmdt = [Select Id,Date__c,Slot__c,Time__c from AllocatedSlotList__mdt Where ]
            
            //System.debug('emailTemplateInvitation sending email'+emailTemplateInvitation);
        
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
       // htmlBodyInvitation = htmlBodyInvitation.replace('{!CustomDate}',);
        //htmlBodyInvitation = htmlBodyInvitation.replace('{!CustomTime}',);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Map<Id,List<String>> mapOfConEmail = new Map<Id,List<String>>();
        List<String> lstOfconEmail;
        List<Id> conId = new List<Id>();
        
      	System.debug('contactList>>'+contacts);
        for(Contact conObj : contacts){
            lstOfconEmail = new List<String>();
            lstOfconEmail.add(conObj.Email);
            subjectInvitation = subjectInvitation.replace('{!Contact.Name}', conObj.Name);
             htmlBodyInvitation = htmlBodyInvitation.replace('{!Contact.Name}', conObj.Name);
            htmlBodyInvitation = htmlBodyInvitation.replace('{!Contact.Position__c}', conObj.Position__c);
            mapOfConEmail.put(conObj.Id,lstOfconEmail);
            conId.add(conObj.Id);
        }
           system.debug('subjectInvitation>>'+subjectInvitation);
    //  system.debug('email list'+lstOfconEmail);
        for(Id consId : conId){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setUseSignature(false); 
            mail.setBccSender(false); 
            mail.setSaveAsActivity(false);
            mail.setTemplateID(emailTemplateInvitation.Id); 
            mail.setToAddresses(mapOfConEmail.get(consId));                        
            mail.setSubject(subjectInvitation);
            mail.setHtmlBody(htmlBodyInvitation);
            mail.setCharset('UTF-8');
            mail.setOrgWideEmailAddressId(orgEmailID.Id); 
            mails.add(mail);
        }
       
        try {
              system.debug('inside the try');
             Messaging.sendEmail(mails);
          
        } catch (Exception e) {
            System.debug('Error sending emails: ' + e.getMessage());
        }
    }
}