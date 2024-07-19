@isTest
public class InvockedByCallsFLowTest {
    
    @isTest
    static void testCreateCallTasks() {
        // Create test data
        Hospital_Privilege_Application__c testHPA = new Hospital_Privilege_Application__c();
        insert testHPA;

        InvockedByCallsFLow.ContentCallInput testInput = new InvockedByCallsFLow.ContentCallInput();
        testInput.Subject = 'Test Subject';
        testInput.ContentScreen = 'Test Content';
        testInput.TaskType = 'Test Type';
        testInput.TaskStatus = 'Completed';
        testInput.HospitalPrivilegeAppRecords = new List<Hospital_Privilege_Application__c>{testHPA};

        List<InvockedByCallsFLow.ContentCallInput> testInputList = new List<InvockedByCallsFLow.ContentCallInput>{testInput};

        // Call the method
        Test.startTest();
        InvockedByCallsFLow.CreateCallTasks(testInputList);
        Test.stopTest();

        // Verify the results
        List<Task> insertedTasks = [SELECT Id, Subject, Description, Type, Status, TaskSubtype, WhatId FROM Task];
        System.assertEquals(1, insertedTasks.size());
        Task insertedTask = insertedTasks[0];
        System.assertEquals(testInput.Subject, insertedTask.Subject);
        System.assertEquals(testInput.ContentScreen, insertedTask.Description);
        System.assertEquals(testInput.TaskType, insertedTask.Type);
        System.assertEquals(testInput.TaskStatus, insertedTask.Status);

        List<Hospital_Privilege_Application__c> updatedHPAs = [SELECT Id FROM Hospital_Privilege_Application__c WHERE Id = :testHPA.Id];
        System.assertEquals(1, updatedHPAs.size());
        Hospital_Privilege_Application__c updatedHPA = updatedHPAs[0];
        // Add additional assertions based on your logic

        // Clean up
        delete insertedTasks;
        // Additional clean up as needed
    }
}