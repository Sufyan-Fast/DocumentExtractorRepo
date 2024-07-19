public class TelecareIntegHosAffUpdCallout implements Queueable, Database.AllowsCallouts{

    protected list<Hospital_Affiliation__c> HosAffLst;
    public Hospital_Affiliation__c hosAffRec;
    
    Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, HosAffUpdateEndpoint__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    public Final String EndpointForUpdate = getEndpoint.HosAffUpdateEndpoint__c;
    public Final String SecretKey = getEndpoint.Secret_Key__c;
    
    public TelecareIntegHosAffUpdCallout( list<Hospital_Affiliation__c> HosAffLst,Hospital_Affiliation__c hosAffRec ){
        
        this.HosAffLst = HosAffLst;
		this.hosAffRec = hosAffRec;
    }
     
   
    public void execute( QueueableContext QContext ){
        
        Integer sentCount = 0;
        Boolean hitLimit = false;
     
        list<Telecare_Integration_Log__c> telLog = new list<Telecare_Integration_Log__c>();
        list<TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper> HsoAffPayload = generateHosAffJSON( HosAffLst );
        system.debug(HsoAffPayload);
        
        for( TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper JsonUpdatedPayload : HsoAffPayload ){
            
            System.debug('Limits.getCallouts()=> ' + Limits.getCallouts()  + ' Limits.getLimitCallouts()=> ' +  Limits.getLimitCallouts() );
               if (Limits.getCallouts() == Limits.getLimitCallouts()) {
            hitLimit = true;
           break;
        }
            
            HttpResponse response = Callout( JsonUpdatedPayload );
            system.debug(response);
            
            if (response.getStatusCode() == 200) {                
                System.debug('POST request successful. Response: ' + response.getBody());
                
                map<string, object> responseMap =  (map<string, object>) Json.deserializeUntyped(response.getBody());
                system.debug(responseMap); 
                
                if(responseMap.get('status')==-1){
                    system.debug('There was some error');
                    system.debug(responseMap);
                     Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                     HAFF_Logs.Status__c = 'Error';
                     HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonUpdatedPayload);
                     HAFF_Logs.Record_Id__c = hosAffRec.Id;
                     telLog.add(HAFF_Logs);
                }else{
                   system.debug('The response was succesful');
                   system.debug(responseMap);
                   Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                   HAFF_Logs.Status__c = 'Success';
                   HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonUpdatedPayload);
                   HAFF_Logs.Record_Id__c = hosAffRec.Id;
                   telLog.add(HAFF_Logs);
                }
                                
                
            }
            
            sentCount++;
            System.debug('sentCount=>' + sentCount);
        }
        
          if(!telLog.isEmpty())
        {
		Insert telLog;
        } 
        
        
        if (hitLimit) {
        // Need to chain this queueable to finish processing. First clean up
        // the list of leads needing a callout, removing all those that have
        // been sent already
        for (Integer index = 0; index < sentCount; index++) {
            HosAffLst.remove(0);
        }

        // Now ensure the remainder get processed by simply re-enqueuing this
        // queueable with its adjusted state
        System.enqueueJob(this);
    }
    }
    
    
    Public HttpResponse Callout( TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper JsonUpdatedPayload ){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, HosAffUpdateEndpoint__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        //String EndpointForUpdate = getEndpoint.HosAffUpdateEndpoint__c;
        
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(EndpointForUpdate);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');           
            System.debug(JsonUpdatedPayload);
            request.setBody(JSON.serializePretty(JsonUpdatedPayload, false));
            request.setTimeout(60000);
            system.debug(request);
            
            HttpResponse response = http.send(request);
            Return response;
        
    }
    
    
    
    
    
    
        
        
    @TestVisible
    private list<TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper> generateHosAffJSON( list<Hospital_Affiliation__c> HosAffLst ){
        
        list<TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper> HosAffDataUpdatedInstanceList = new list<TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper>();
        
        list<Id> ConIds = new List<Id>();
        for( Hospital_Affiliation__c HosAff : HosAffLst ){
             ConIds.add(HosAff.Provider__c);
        }
        map<id, Contact> ConEntMap = new Map<id, Contact>( [Select Id, TelecareId__c from Contact where Id in: ConIds] );
        
        
        for(Hospital_Affiliation__c HosAff : HosAffLst){            
            HosAffDataUpdatedInstanceList.add( generateHosAffJSONWrapper(HosAff, ConEntMap) );                        
        }
         
        system.debug(HosAffDataUpdatedInstanceList);
        return HosAffDataUpdatedInstanceList;
         
    }
    
    
    @TestVisible
    Private TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper generateHosAffJSONWrapper( Hospital_Affiliation__c HsAff, map<id, Contact> ConEntMap){

        TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper HosAffUpdatedDataInstance = new TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper();
 
            Contact con = ConEntMap.get(HsAff.Provider__c);
        
            HosAffUpdatedDataInstance.telercare_user_id = con.TelecareId__c;
            HosAffUpdatedDataInstance.salesforce_user_id = HsAff.Provider__c;
            HosAffUpdatedDataInstance.credentialing_entity = HsAff.Credentialing_Entity_Name__c; 
            HosAffUpdatedDataInstance.credentialing_entity_id = HsAff.Credentialing_Entity__c;
            HosAffUpdatedDataInstance.start_date = string.valueOf(HsAff.From__c);
            HosAffUpdatedDataInstance.end_date = string.valueOf(HsAff.To__c);              
            HosAffUpdatedDataInstance.is_active = string.valueOf(HsAff.Affiliation_Status__c);
            HosAffUpdatedDataInstance.SecretKey = SecretKey;
        	HosAffUpdatedDataInstance.ApprovalDate = string.valueOf(HsAff.Approval_Date__c);
           
            
        
            system.debug(HosAffUpdatedDataInstance);        
            return HosAffUpdatedDataInstance;
        
    }
  
    public Telecare_Integration_Log__c hosAffLogs( String responseBody ){
        map<string, object> ResponseMap =  (map<string, object>) Json.deserializeUntyped(responseBody);
        system.debug(ResponseMap);
         
        Telecare_Integration_Log__c HALogs = new Telecare_Integration_Log__c();
        HALogs.Message__c = (String)ResponseMap.get('msg');
        HALogs.Data__c = String.valueof(ResponseMap.get('data'));
        HALogs.Status_Code__c = String.valueof(ResponseMap.get('status'));
        HALogs.Response_Body__c = responseBody;
        HALogs.Object_Name__c = 'Hospital_Affiliation__c';
        
        return HALogs;
    }
   
    
    
    
}