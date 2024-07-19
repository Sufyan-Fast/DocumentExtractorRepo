public class TelecareIntegLicenseHandler {
    
    public static void AFTER_INSERT_UPDATE( list<License__c> LicLst, map<Id, Contact> ContMap, License__c LicRec ){
        
       TelecareIntegLicenseCallout LicUpdateCallInstance = new TelecareIntegLicenseCallout( LicLst, ContMap, LicRec);
       system.enqueueJob(LicUpdateCallInstance);     
        
    }        
    
    
}