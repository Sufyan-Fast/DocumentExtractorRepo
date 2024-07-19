public class TelecareIntegrationContactTriggerHandler {

    public static void AFTER_INSERT( list<Contact> Newcontlist, contact contct){
        
        TelecareIntegrationContactTriggerCallout telecareCallIntnse = new TelecareIntegrationContactTriggerCallout( Newcontlist, contct );
        system.enqueueJob(telecareCallIntnse);

    }
    
    public static void AFTER_UPDATE( list<Contact> UPdatedcontlist, contact UPdatedcontct ){
        
        TelecareIntegrationContactUpdatedCallout telecareUpdateCallIntnse = new TelecareIntegrationContactUpdatedCallout( UPdatedcontlist, UPdatedcontct );
        system.enqueueJob(telecareUpdateCallIntnse);    
        
    }
   
    
}