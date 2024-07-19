public class TelecareIntegHosAffHandler {

    public static void AFTER_UPDATE( list<Hospital_Affiliation__c> HosAffLst, Hospital_Affiliation__c hosAffRec){
        
       TelecareIntegHosAffUpdCallout HosAffUpdateCallInstance = new TelecareIntegHosAffUpdCallout( HosAffLst,hosAffRec );
       system.enqueueJob(HosAffUpdateCallInstance);    
        
    }
    
    public static void AFTER_INSERT( list<Hospital_Affiliation__c> HosAffLst, Hospital_Affiliation__c hosAffRec ){
        
       TelecareIntegHosAffUpdCallout HosAffUpdateCallInstance = new TelecareIntegHosAffUpdCallout( HosAffLst,hosAffRec);
       system.enqueueJob(HosAffUpdateCallInstance);    
        
    }
    
    
}