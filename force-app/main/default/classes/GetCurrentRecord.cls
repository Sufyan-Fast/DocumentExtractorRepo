public with sharing class GetCurrentRecord {
    @AuraEnabled(Cacheable=true)
    public static Shift_Retention_Orientation__c getRecord(Id recordId)    
    {
        try{
            return [Select Id, Name ,ContactId__r.Name,Specialty__c From Shift_Retention_Orientation__c Where Id =: recordId Limit 1];
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}