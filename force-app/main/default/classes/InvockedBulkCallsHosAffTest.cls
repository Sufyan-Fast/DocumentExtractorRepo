@isTest
public class InvockedBulkCallsHosAffTest {

    @isTest
    static void testCreateCallTasks() {
        // Create test data
        Hospital_Affiliation__c testHospitalAffiliation = new Hospital_Affiliation__c();
        insert testHospitalAffiliation;

        InvockedBulkCallsHospitalAffliliation.ContentCallInput testInput = new InvockedBulkCallsHospitalAffliliation.ContentCallInput();
        testInput.Subject = 'Test Subject';
        testInput.ContentScreen = 'Test Content';
        testInput.TaskType = 'Test Type';
        testInput.TaskStatus = 'Completed';
        testInput.HospitalAffiliation = new List<Hospital_Affiliation__c>{testHospitalAffiliation};

        List<InvockedBulkCallsHospitalAffliliation.ContentCallInput> testInputList = new List<InvockedBulkCallsHospitalAffliliation.ContentCallInput>{testInput};

        // Call the method
        Test.startTest();
        InvockedBulkCallsHospitalAffliliation.CreateCallTasks(testInputList);
        Test.stopTest();

        // Verify the results
        List<Task> insertedTasks = [SELECT Id, Subject, Description, Type, Status, TaskSubtype, WhatId FROM Task];
        System.assertEquals(1, insertedTasks.size());
        Task insertedTask = insertedTasks[0];
        System.assertEquals(testInput.Subject, insertedTask.Subject);
        System.assertEquals(testInput.ContentScreen, insertedTask.Description);
        System.assertEquals(testInput.TaskType, insertedTask.Type);
        System.assertEquals(testInput.TaskStatus, insertedTask.Status);

        List<Hospital_Affiliation__c> updatedHospitalAffiliations = [SELECT Id FROM Hospital_Affiliation__c WHERE Id = :testHospitalAffiliation.Id];
        System.assertEquals(1, updatedHospitalAffiliations.size());
        Hospital_Affiliation__c updatedHospitalAffiliation = updatedHospitalAffiliations[0];
        // Add additional assertions based on your logic

        // Clean up
        delete insertedTasks;
        // Additional clean up as needed
    }
}