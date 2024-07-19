//@RestResource(urlMapping='/updateFacility/*')
global with sharing class AccountResourceFirst {
  //  @HttpPatch
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
            if (acc.TS_Account_ID__c != null) {
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
                    updatedAccountIds.add(existingAccount.Id);
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
   
 
   
   
   
   
 
}