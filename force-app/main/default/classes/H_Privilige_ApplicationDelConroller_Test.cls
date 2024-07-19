@isTest
private class H_Privilige_ApplicationDelConroller_Test {
    // Test method to cover the checkPermissionAndRedirect method
    static testMethod void testCheckPermissionAndRedirect() {
        // Create a test Hospital_Affiliation__c record
        Hospital_Affiliation__c testHAF = new Hospital_Affiliation__c(/* fill in required fields */);
        insert testHAF;
        
        // Create a test user with the required permission set
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Credentialing_Add_New_Credentialing_Entities' LIMIT 1];
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]; // Assuming 'System Administrator' profile has no additional permissions
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = testProfile.Id
        );
        insert testUser;
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        
        // Set the current user context to the test user
        System.runAs(testUser) {
            // Instantiate the controller with the test record
            ApexPages.StandardController sc = new ApexPages.StandardController(testHAF);
            H_Privilige_ApplicationDelConroller controller = new H_Privilige_ApplicationDelConroller(sc);
            
            // Call the checkPermissionAndRedirect method
            PageReference result = controller.checkPermissionAndRedirect();
            
            // Assert that the showDialog variable is set to true
            System.assertEquals(true, controller.showDialog);
            // Assert that the result is null (since it should not redirect)
            System.assertEquals(null, result);
            
            // Check if the Visualforce page is rendered correctly
            String vfPageContent = result.getContent().toString();
            System.assert(vfPageContent.contains('Do you want to delete the affiliated/corresponding HAP records?'));
            System.assert(vfPageContent.contains('<apex:commandButton value="Yes" action="{!confirmDelete}" styleClass="btn-yes" rerender="dialogPanel" />'));
            System.assert(vfPageContent.contains('<apex:commandButton value="No" action="{!cancelDelete}" styleClass="btn-no" rerender="dialogPanel" />'));
        }
    }
    
    // Test method to cover the confirmDelete method
    static testMethod void testConfirmDelete() {
        // Create a test Hospital_Affiliation__c record
        Hospital_Affiliation__c testHAF = new Hospital_Affiliation__c(/* fill in required fields */);
        insert testHAF;
        
        // Instantiate the controller with the test record
        ApexPages.StandardController sc = new ApexPages.StandardController(testHAF);
        H_Privilige_ApplicationDelConroller controller = new H_Privilige_ApplicationDelConroller(sc);
        
        // Set the showDialog variable to true
        controller.showDialog = true;
        
        // Call the confirmDelete method
        PageReference result = controller.confirmDelete();
        
        // Assert that the record is deleted
        System.assertEquals(null, [SELECT Id FROM Hospital_Affiliation__c WHERE Id = :testHAF.Id]);
        // Assert that the result redirects to the specified page
        System.assertEquals('/a2g', result.getUrl());
    }
    
    // Test method to cover the cancelDelete method
    static testMethod void testCancelDelete() {
        // Create a test Hospital_Affiliation__c record
        Hospital_Affiliation__c testHAF = new Hospital_Affiliation__c(/* fill in required fields */);
        insert testHAF;
        
        // Instantiate the controller with the test record
        ApexPages.StandardController sc = new ApexPages.StandardController(testHAF);
        H_Privilige_ApplicationDelConroller controller = new H_Privilige_ApplicationDelConroller(sc);
        
        // Call the cancelDelete method
        PageReference result = controller.cancelDelete();
        
        // Assert that the record is deleted
        System.assertEquals(null, [SELECT Id FROM Hospital_Affiliation__c WHERE Id = :testHAF.Id]);
        // Assert that the result redirects to the specified page
        System.assertEquals('/a2g', result.getUrl());
    }
}