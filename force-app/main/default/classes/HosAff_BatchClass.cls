Public class HosAff_BatchClass implements Database.Batchable<SObject> {

    Public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, isChecked__c FROM Hospital_Affiliation__c';
        return Database.getQueryLocator(query);
    }

    Public void execute(Database.BatchableContext BC, List<Hospital_Affiliation__c> HosAffsList) {
       
        list<Hospital_Affiliation__c> HosAffLst = new list<Hospital_Affiliation__c>();
        for(Hospital_Affiliation__c HosAff : HosAffsList){
            HosAff.isChecked__c = True;
            HosAffLst.add(HosAff);
        }
        List<Database.saveResult> Results = Database.Update(HosAffLst, false);
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

    Public void finish(Database.BatchableContext BC) {
        /*
            HosAff_BatchClass UpdateHosAffs = new Licence_BatchClass();
            Database.executeBatch(UpdateLIc, 10);
        */
        
    }
}