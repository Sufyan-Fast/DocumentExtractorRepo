@isTest
private class TestInvockedBulkCallsHAffliliation {

    @isTest
    static void testCreateCallTasksWithRecords() {
        // Create test data
        Hospital_Affiliation__c testHPA = new Hospital_Affiliation__c(/* Add necessary fields */);
        insert testHPA;

        InvockedBulkCallsHospitalAffliliation.ContentCallInput input = new InvockedBulkCallsHospitalAffliliation.ContentCallInput();
        input.Subject = 'Test Subject';
        input.ContentScreen = 'Test Content';
        input.TaskType = 'Test Type';
        input.TaskStatus = 'Test Status';
        input.HospitalAffiliation = new List<Hospital_Affiliation__c>{ testHPA };

        List<InvockedBulkCallsHospitalAffliliation.ContentCallInput> inputList = new List<InvockedBulkCallsHospitalAffliliation.ContentCallInput>{ input };

        Test.startTest();
        // Call the invocable method
        InvockedBulkCallsHospitalAffliliation.CreateCallTasks(inputList);
        Test.stopTest();

        // Retrieve inserted Task records
        List<Task> insertedTasks = [SELECT Id, Subject, Description, Type, Status, TaskSubtype, WhatId FROM Task];

        // Assertion to check if Task records were inserted
        System.assertEquals(1, insertedTasks.size(), 'Task record not inserted.');
        System.assertEquals('Test Subject', insertedTasks[0].Subject, 'Subject not set correctly.');
        System.assertEquals('Test Content', insertedTasks[0].Description, 'Description not set correctly.');
        // Add more assertions for other fields as needed

        // Check if ListtoUpdateCalls were updated
        List<Hospital_Affiliation__c> updatedHPAs = [SELECT Id FROM Hospital_Affiliation__c WHERE Id = :testHPA.Id];
        // Perform assertions to ensure ListtoUpdateCalls were updated as expected
        System.assertNotEquals(null, updatedHPAs[0].Affiliation_Status__c, 'ListtoUpdateCalls were not updated.');

        // Check if taskList was populated correctly
        List<Task> queriedTasks = [SELECT Id, Subject, Description, Type, Status, TaskSubtype, WhatId FROM Task WHERE WhatId = :testHPA.Id];
        System.assertEquals(1, queriedTasks.size(), 'Task list not populated correctly.');
        System.assertEquals('Test Subject', queriedTasks[0].Subject, 'Task Subject not set correctly.');
        // Add more assertions for other task fields
    }

    // Other test methods for different scenarios can be added here
}