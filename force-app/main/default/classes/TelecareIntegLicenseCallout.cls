public class TelecareIntegLicenseCallout Implements Queueable, Database.AllowsCallouts{
    
    protected list<License__c> LicLst;
    protected map<Id, Contact> ContMap;
    public License__c LicRec;
    
    Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, LicUpdateEndpoint__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    protected Final String EndpointForUpdate = getEndpoint.LicUpdateEndpoint__c;
    protected Final String SecretKey = getEndpoint.Secret_Key__c;
    
    public TelecareIntegLicenseCallout( list<License__c> LicLst, map<Id, Contact> ContMap, License__c LicRec ){
        
        this.LicLst = LicLst;
        this.ContMap = ContMap;
        this.LicRec = LicRec;
    }
     
    
    public void execute( QueueableContext QContext ) {
        
        Integer sentCount = 0;
        Boolean hitLimit = false;
        
        list<Telecare_Integration_Log__c> telLog = new list<Telecare_Integration_Log__c>();
        list<TelecareJSONWrapperClass.ProviderLicenseInformation> LicPayload = generateHosAffJSON( LicLst );
        system.debug(LicPayload);
        
            
        for( TelecareJSONWrapperClass.ProviderLicenseInformation JsonUpdatedPayload : LicPayload ){
            
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
                     HAFF_Logs.Record_Id__c = LicRec.Id;
                     telLog.add(HAFF_Logs);
                }else{
                   system.debug('The response was succesful');
                   system.debug(responseMap);
                   Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                   HAFF_Logs.Status__c = 'Success';
                   HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonUpdatedPayload);
                   HAFF_Logs.Record_Id__c = LicRec.Id;
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
            LicLst.remove(0);
        }

        // Now ensure the remainder get processed by simply re-enqueuing this
        // queueable with its adjusted state
        System.enqueueJob(this);
    }
                                                           
    }
    
     Public HttpResponse Callout( TelecareJSONWrapperClass.ProviderLicenseInformation JsonUpdatedPayload ){
                
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
    
                    
    
     public list<TelecareJSONWrapperClass.ProviderLicenseInformation> generateHosAffJSON( list<License__c> LicLst ){
        
        list<TelecareJSONWrapperClass.ProviderLicenseInformation> licWrapperInstanceList = new list<TelecareJSONWrapperClass.ProviderLicenseInformation>();
        
        for(License__c lic : LicLst){            
            licWrapperInstanceList.add( generateHosAffJSONWrapper(lic) );                        
        }
         
        system.debug(licWrapperInstanceList);
        return licWrapperInstanceList;
         
    }
    
    
    
    public TelecareJSONWrapperClass.ProviderLicenseInformation generateHosAffJSONWrapper( License__c lic ){

        TelecareJSONWrapperClass.ProviderLicenseInformation licWrapperInstance = new TelecareJSONWrapperClass.ProviderLicenseInformation();
        
            Contact con = ContMap.get( lic.Provider__c );
        
            licWrapperInstance.telecare_user_id = con.TelecareId__c;
            licWrapperInstance.salesforce_user_id = con.Id;
            licWrapperInstance.license_number = lic.License_Number__c;
            licWrapperInstance.license_type_id = lic.License_Type_ID__c;
            licWrapperInstance.license_type_name = lic.License_Type__c;
            licWrapperInstance.issued_date = string.valueof(lic.Issue_Date__c);
            licWrapperInstance.expired_date = string.valueof(lic.Expiration_Date__c);
            //licWrapperInstance.licensure_board_id = '';
            //licWrapperInstance.licensure_board_name = '';
            licWrapperInstance.is_active = string.valueof(lic.In_Use__c);
            licWrapperInstance.license_state = string.valueof(lic.Jurisdiction_State_picklist__c);
            licWrapperInstance.SecretKey = SecretKey;
        	
                                    
                                    
            system.debug( licWrapperInstance );        
            return licWrapperInstance;
        
    }
   
     public Telecare_Integration_Log__c hosAffLogs( String responseBody ){
        map<string, object> ResponseMap =  (map<string, object>) Json.deserializeUntyped(responseBody);
        system.debug(ResponseMap);
         
        Telecare_Integration_Log__c HALogs = new Telecare_Integration_Log__c();
        HALogs.Message__c = (String)ResponseMap.get('msg');
        HALogs.Data__c = String.valueof(ResponseMap.get('data'));
        HALogs.Status_Code__c = String.valueof(ResponseMap.get('status'));
        HALogs.Response_Body__c = responseBody;
        HALogs.Object_Name__c = 'License__c'; 
        
        return HALogs;
    }
    

    
}