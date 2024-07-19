@isTest
private class LeadBatchClassTest {
    
    @isTest
    static void testBatchClass() {
        
        // custom setting records
        
        list<RecEventProdInactive__c> batchCls = new list<RecEventProdInactive__c>();
        
        RecEventProdInactive__c css = new RecEventProdInactive__c();
        css.name = 'CheckActiveForTrigger';
        css.isActive__c = true; 
        batchCls.add(css);
        
        RecEventProdInactive__c cs = new RecEventProdInactive__c();
        cs.name = 'CheckActiveForContactConversion';
        cs.isActive__c = false; 
        batchCls.add(cs);
        
        insert batchCls; 
        
        
        // Create test leads
                
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            Lead l = new Lead();
            l.FirstName = 'Test ' + i;
            l.LastName = 'Lead';
            l.Email = 'test' + i + '@example.com';
            l.Company = 'Test Company ' + i;
            l.Status = 'Open';
            testLeads.add(l);
        }
        insert testLeads;
        
        // Run batch job
        Test.startTest();
        LeadBatchClass batch = new LeadBatchClass();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that test checkpoint field was updated for all leads
        List<Lead> updatedLeads = [SELECT Id, testCheckPoint__c FROM Lead];
        System.assertEquals(testLeads.size(), updatedLeads.size());
        for (Lead l : updatedLeads) {
            System.assertEquals(true, l.testCheckPoint__c);
        }
    }
}