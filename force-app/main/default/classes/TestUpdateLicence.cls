@isTest
private class TestUpdateLicence {
    
    @isTest
    static void testBatchClass() {
    
        List<License__c> testLicenses = new List<License__c>();       
        License__c lic = new License__c();
        lic.Name = 'Test1';
        lic.isBoolean__c = False;
        testLicenses.add(lic);
        insert testLicenses;

        // Start the batch class
        Test.startTest();
        Licence_BatchClass myBatch = new Licence_BatchClass();
        Database.executeBatch(myBatch, 10);
        Test.stopTest();

        // Validate the results or add additional assertions as needed
        //List<License__c> updatedLicenses = [SELECT Id, isBoolean__c FROM License__c WHERE isBoolean__c = true LIMIT 200];
        //System.assertEquals(200, updatedLicenses.size(), 'All licenses should be updated');
    }
}