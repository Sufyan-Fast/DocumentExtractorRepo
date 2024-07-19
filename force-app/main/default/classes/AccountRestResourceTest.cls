@isTest
private class AccountRestResourceTest {

    @isTest
    static void testUpdateAccounts() {
        // Create test data
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                TS_Account_ID__c = 'TSID00' + i,
                RCM__c = 'Facility'
            );
            testAccounts.add(acc);
        }
        insert testAccounts;
        
           List<Account> updatedAccounts = new List<Account>();
        for (Account acc : testAccounts) {
            
            acc.RCM__c = 'Not Billing';
            updatedAccounts.add(acc);
        }

        // Prepare mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateFacility/';
         req.requestBody = Blob.valueOf(JSON.serialize(updatedAccounts));
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        // Call the REST service
        AccountRestResource.updateAccounts(updatedAccounts);

        // Verify response status code
        System.assertEquals(200, res.statusCode);

        // Verify response body
        System.assertNotEquals(null, res.responseBody);
    }

    // Add more test methods as needed
     @isTest
    static void testErrorAccounts() {
        // Create test data
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                TS_Account_ID__c = 'TSID00' + i,
                RCM__c = 'Facility'
            );
            testAccounts.add(acc);
        }
        insert testAccounts;
        
           List<Account> updatedAccounts = new List<Account>();
        for (Account acc : testAccounts) {
            
             acc.RCM__c = 'Not valid';
            updatedAccounts.add(acc);
        }

        // Prepare mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateFacility/';
         req.requestBody = Blob.valueOf(JSON.serialize(updatedAccounts));
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        // Call the REST service
        AccountRestResource.updateAccounts(updatedAccounts);

        // Verify response status code
        System.assertEquals(400, res.statusCode);

        // Verify response body
        System.assertNotEquals(null, res.responseBody);
    }
    


}