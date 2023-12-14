@isTest
public class mapControllerTest {

    @isTest
    static void testSubmitForm() {
        // Create a test user
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer milliSec = DateTime.now().millisecond();
        User testUser = new User(LastName = 'StandardUser', 
                                        Alias = 'standt', 
                                        Email = 'standarduser@testorg.com' + milliSec, 
                                        EmailEncodingKey = 'UTF-8',
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey = 'en_US', 
                                        ProfileId = objProfile.Id, 
                                        TimeZoneSidKey = 'America/Los_Angeles', 
                                        UserName = 'standt@testorg.com' + milliSec);
        insert testUser;

        // Create a contact for the test user
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com'
        );
        insert testContact;

        // Set the running user to the test user
        System.runAs(testUser) {
            // Create an instance of the controller
            MapController controller = new MapController();
            
            // Set user email for testing
            controller.userEmail = 'test@example.com';

            // Call the submitForm method
            PageReference resultPage = controller.submitForm();

            // Assertions
            System.assert(controller.errorMessage, 'Error message should be true for non-existing user');
            System.assertEquals(null, resultPage, 'PageReference should be null');
        }
    }

    @isTest
    static void testSubmitData() {
        // Create a test user
		Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer milliSec = DateTime.now().millisecond();
        User testUser = new User(LastName = 'StandardUser', 
                                        Alias = 'standt', 
                                        Email = 'standarduser@testorg.com' + milliSec, 
                                        EmailEncodingKey = 'UTF-8',
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey = 'en_US', 
                                        ProfileId = objProfile.Id, 
                                        TimeZoneSidKey = 'America/Los_Angeles', 
                                        UserName = 'standt@testorg.com' + milliSec);
        insert testUser;
        // Create a contact for the test user
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com'
        );
        insert testContact;

        // Set the running user to the test user
        System.runAs(testUser) {
            // Create an instance of the controller
            MapController controller = new MapController();

            // Set user email for testing
            controller.userEmail = 'test@example.com';


            // Set test questions for the controller
            controller.qns = [SELECT Id, Answer__c, Options__c, Questions__c FROM Questions_answers__mdt];

            // Call the submitData method
            Test.startTest();
            Contact testContact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com'
        );
        insert testContact1;
            controller.submitData();
            controller.getMapEntries();
            Test.stopTest();

            // Assertions
            System.assertEquals(false, controller.displayExmForm, 'displayExmForm should be true');
            System.assertEquals(1, controller.objcontRecordResult.size(), 'One contact record should be queried');
            System.assertEquals('First Round - Rejected', controller.objcontRecordResult[0].Interview_Status__c, 'Interview status should be "First Round - Rejected"');
        }
    }
}