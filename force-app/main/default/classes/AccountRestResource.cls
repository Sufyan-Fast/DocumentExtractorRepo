@RestResource(urlMapping='/updateFacility/*')
global with sharing class AccountRestResource {



/*
    @HttpPatch
    global static ID updateAccount(String accId, String rcm) {
        RestRequest request = RestContext.request;
        // String caseId = request.requestURI.substring(
        //     request.requestURI.lastIndexOf('/')+1);
        Account thisAccount = [SELECT Id,RCM__c FROM Account WHERE TS_Account_ID__c = :accId];

        thisAccount.RCM__c = rcm;
        update thisAccount;
        return thisAccount.Id;
    }*/

    /*
    @HttpPatch
    global static List<String> updateAccounts(List<Account> accounts) {
        List<String> updatedAccountIds = new List<String>();
    
        System.debug('Entered updateAccounts method with ' + accounts.size() + ' accounts');
        System.debug('Accounts: ' + accounts);
    
        // Collect TS_Account_ID__c values from the list of Account records
        Set<String> accountIds = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();
    
        // Prepare a list to hold updated Account records
        List<Account> accountsToUpdate = new List<Account>();
    
        // Populate accountIds set and accountMap for  data retrieval
        for (Account acc : accounts) {
            if (acc.TS_Account_ID__c != null && acc.TS_Account_ID__c != '' && acc.RCM__c != '') {
        System.debug(' acc.TS_Account_ID__c: ' +  acc.TS_Account_ID__c);
                accountIds.add(acc.TS_Account_ID__c);
                accountMap.put(acc.TS_Account_ID__c, acc);
            }
        }
    
        try {
            // Query all relevant Account records based on TS_Account_ID__c values
            for (Account existingAccount : [SELECT Id, RCM__c,TS_Account_ID__c FROM Account WHERE TS_Account_ID__c IN :accountIds]) {
                String accId = existingAccount.TS_Account_ID__c;
                String rcm = accountMap.get(accId).RCM__c;
    
                // Update  RCM__c field 
                if (rcm != null && existingAccount.RCM__c != rcm) {
                    existingAccount.RCM__c = rcm;
                    accountsToUpdate.add(existingAccount); 
                    updatedAccountIds.add('Facility with TS Account ID : '+existingAccount.TS_Account_ID__c + ' has been updated with New value = ' + rcm );

                }
            }
    
            // Perform DML
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
                System.debug('Updated Account Ids: ' + updatedAccountIds);
            }
        } catch (Exception e) {
         
            System.debug('Error updating accounts: ' + e.getMessage());
  
        }
    
        return updatedAccountIds; 
    }
    */
    





/*
        @HttpPatch
        global static void updateAccounts(List<Account> accounts) {
            List<String> updatedAccountIds = new List<String>();
            RestResponse res = RestContext.response;

    
            // System.debug('Entered updateAccounts method with ' + accounts.size() + ' accounts');
            // System.debug('Accounts: ' + accounts);
    
            // Collect TS_Account_ID__c values from the list of Account records
            Set<String> accountIds = new Set<String>();
            Map<String, Account> accountMap = new Map<String, Account>();
    
            // Prepare a list to hold updated Account records
            List<Account> accountsToUpdate = new List<Account>();
    
            // Populate accountIds set and accountMap for data retrieval
            for (Account acc : accounts) {
                if (acc.TS_Account_ID__c != null && acc.TS_Account_ID__c != '' && acc.RCM__c != '') {
                    System.debug('acc.TS_Account_ID__c: ' + acc.TS_Account_ID__c);
                    accountIds.add(acc.TS_Account_ID__c);
                    accountMap.put(acc.TS_Account_ID__c, acc);
                }
            }
    
            try {

                // Query all relevant Account records based on TS_Account_ID__c values
                for (Account existingAccount : [SELECT Id, RCM__c, TS_Account_ID__c FROM Account WHERE TS_Account_ID__c IN :accountIds]) {
                System.debug('existingAccount'+existingAccount);
                    String accId = existingAccount.TS_Account_ID__c;
                    String rcm = accountMap.get(accId).RCM__c;
    
                    // Update RCM__c field
                    if (rcm != null && rcm != '' ) {
                        existingAccount.RCM__c = rcm;
                        accountsToUpdate.add(existingAccount);
                    }
                    
                }
    
                        // Perform DML
        if (!accountsToUpdate.isEmpty()) {
            System.debug('accountsToUpdate');
            List<Database.SaveResult> results = Database.update(accountsToUpdate, false);

            List<String> successMessages = new List<String>();
            List<String> errorMessages = new List<String>();

            // Iterate through the results to determine success and errors
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successMessages.add('Facility with TS Account ID: ' + accountsToUpdate[i].TS_Account_ID__c + ' has been updated');
                } else {
                    errorMessages.add('Error updating Facility with TS Account ID: ' + accountsToUpdate[i].TS_Account_ID__c + ', Error: ' + results[i].getErrors()[0].getMessage());
                }
            }

            // Construct response based on success and errors
            if (!successMessages.isEmpty()) {
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(successMessages));
                res.statusCode = 200;
            }

            if (!errorMessages.isEmpty()) {
                res.addHeader('Content-Type', 'text/plain');
                res.responseBody = Blob.valueOf(String.join(errorMessages, '\n'));
                res.statusCode = 400;
            }
        } else {
            res.addHeader('Content-Type', 'text/plain');
            res.responseBody = Blob.valueOf('INVALID_OR_NULL_TS_Account_ID__c OR RCM__c value');
            res.statusCode = 400;
        }
    } catch (Exception e) {
        System.debug('Error updating accounts: ' + e.getMessage());

        // Set response status to 400 Bad Request and return the error message
        res.addHeader('Content-Type', 'text/plain');
        res.responseBody = Blob.valueOf('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, RCM: bad value for restricted picklist field: RCM__c');
        res.statusCode = 400;
    }
}*/

@HttpPatch
global static void updateAccounts(List<Account> accounts) {
    RestResponse res = RestContext.response;

    Set<String> accountIds = new Set<String>();
    Map<String, Account> accountMap = new Map<String, Account>();

    // Populate accountIds set and accountMap for data retrieval
    populateAccountMap(accounts, accountIds, accountMap);

    try {
        // Query and update accounts
        List<Account> accountsToUpdate = queryAndUpdateAccounts(accountIds, accountMap);

        // Construct response
        constructResponse(res, accountsToUpdate);
    } catch (Exception e) {
        handleException(res, e);
    }
}

private static void populateAccountMap(List<Account> accounts, Set<String> accountIds, Map<String, Account> accountMap) {
    for (Account acc : accounts) {
        if (acc.TS_Account_ID__c != null && acc.TS_Account_ID__c != '' && acc.RCM__c != '') {
            accountIds.add(acc.TS_Account_ID__c);
            accountMap.put(acc.TS_Account_ID__c, acc);
        }
    }
}

private static List<Account> queryAndUpdateAccounts(Set<String> accountIds, Map<String, Account> accountMap) {
    List<Account> accountsToUpdate = new List<Account>();

    for (Account existingAccount : [SELECT Id, RCM__c, TS_Account_ID__c FROM Account WHERE TS_Account_ID__c IN :accountIds]) {
        String accId = existingAccount.TS_Account_ID__c;
        String rcm = accountMap.get(accId).RCM__c;

        if (rcm != null && rcm != '') {
            existingAccount.RCM__c = rcm;
            accountsToUpdate.add(existingAccount);
        }
    }

    // Perform DML
    if (!accountsToUpdate.isEmpty()) {
        List<Database.SaveResult> results = Database.update(accountsToUpdate, true);
        handleSaveResults(results, accountsToUpdate);
    }

    return accountsToUpdate;
}

private static void handleSaveResults(List<Database.SaveResult> results, List<Account> accountsToUpdate) {
    RestResponse res = RestContext.response;
    List<String> successMessages = new List<String>();
    List<String> errorMessages = new List<String>();

    // Iterate through the results to determine success and errors
    for (Integer i = 0; i < results.size(); i++) {
        if (results[i].isSuccess()) {
            successMessages.add('Facility with TS Account ID: ' + accountsToUpdate[i].TS_Account_ID__c + ' has been updated');
        } else {
            errorMessages.add('Error updating Facility with TS Account ID: ' + accountsToUpdate[i].TS_Account_ID__c + ', Error: ' + results[i].getErrors()[0].getMessage());
        }
    }

    // Construct response based on success and errors
    if (!successMessages.isEmpty()) {
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(successMessages));
        res.statusCode = 200;
    }

    if (!errorMessages.isEmpty()) {
        res.addHeader('Content-Type', 'text/plain');
        res.responseBody = Blob.valueOf(String.join(errorMessages, '\n'));
        res.statusCode = 400;
    }
}

private static void constructResponse(RestResponse res, List<Account> accountsToUpdate) {
    if (accountsToUpdate.isEmpty()) {
        res.addHeader('Content-Type', 'text/plain');
        res.responseBody = Blob.valueOf('INVALID_OR_NULL_TS_Account_ID__c OR RCM__c value');
        res.statusCode = 400;
    }
}

private static void handleException(RestResponse res, Exception e) {
    System.debug('Error updating accounts: ' + e.getMessage());

    // Set response status to 400 Bad Request and return the error message
    res.addHeader('Content-Type', 'text/plain');
    res.responseBody = Blob.valueOf('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, RCM: bad value for restricted picklist field: RCM__c');
    res.statusCode = 400;
}

}