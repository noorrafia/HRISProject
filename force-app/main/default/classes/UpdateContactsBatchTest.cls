@isTest
private class UpdateContactsBatchTest {
    @isTest
    static void testUpdateContactsBatch() {
        // Test data setup
        // Create test Contact records without Allocated_Slot__c values
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
          Contact con = new Contact();
                con.FirstName = 'TestFirstName' + i;
                con.LastName = 'TestLastName' + i;
                con.Email = 'test' + i + '@example.com';
                // Allocated_Slot__c is intentionally left blank 
                contacts.add(con);
        }
        insert contacts;
        // Execute the batch class
        Test.startTest();
        UpdateContactsBatch updateContactsBatchInstance = new UpdateContactsBatch();
        Database.executeBatch(updateContactsBatchInstance);
        Test.stopTest();
        // Add assertions as needed to validate the batch execution
        // Example: Query the records and verify the expected changes
        List<Contact> updatedContacts = [SELECT Id, Allocated_Slot__c FROM Contact WHERE Id IN :contacts];
        for (Contact updatedContact : updatedContacts) {
            System.assertEquals(1, updatedContact.Allocated_Slot__c);
        }
        // Additional assertions and validations based on your specific requirements
    }
}
