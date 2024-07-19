global class Licence_BatchClass implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, isBoolean__c, Jurisdiction_State_picklist__c FROM License__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<License__c> LicList) {
       
        list<License__c> LicLst = new list<License__c>();
        for(License__c lic : LicList){
            lic.isBoolean__c = True;
            LicLst.add(lic);
            system.debug(lic.Jurisdiction_State_picklist__c);
        }
        List<Database.saveResult> Results = Database.Update(LicLst);
        for (Database.SaveResult res : Results) {
            if (res.isSuccess()) {
                System.debug('Record Updated Successfully: ' + res.getId());
            } else {
                for (Database.Error err : res.getErrors()) {
                    System.debug('Error updating record: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }  
        }   
        
       
    }

    global void finish(Database.BatchableContext BC) {
        /*
            Licence_BatchClass UpdateLIc = new Licence_BatchClass();
            Database.executeBatch(UpdateLIc, 10);
        */
        
    }
}