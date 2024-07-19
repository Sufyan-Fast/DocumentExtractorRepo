public class TelecareIntegrationContactTriggerCallout implements Queueable, Database.AllowsCallouts {
    
                                    // AFTER_INSERT CALLOUT 
    
    public list<contact> contList;
    public contact contct;
    
    Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    public String EndpointValue = getEndpoint.Value__c;
    public Final String SecretKey = getEndpoint.Secret_Key__c;
    
    public TelecareIntegrationContactTriggerCallout( list<Contact> contList, contact contct ){
        
        this.contList = contList;
        this.contct = contct;
    }
    
    
    public void execute( QueueableContext QContext ){
         list<Telecare_Integration_Log__c> telLog = new list<Telecare_Integration_Log__c>();
        list<TelecareJSONWrapperClass.ContactWrapper> ContactPayload = generateContactJSON( contList );
        system.debug(ContactPayload);
        
        for(TelecareJSONWrapperClass.ContactWrapper JsonPayload : ContactPayload){
            
            HttpResponse response = Callout( JsonPayload );           
                            
                if (response.getStatusCode() == 200) {                   
                    System.debug('POST request successful. Response: ' + response.getBody());
                    
                    map<string, object> responseMap =  (map<string, object>) Json.deserializeUntyped(response.getBody());
                    system.debug(responseMap); 
                    
                    if(responseMap.get('status')==0){                        
                        
                        String IdData = (String) responseMap.get('data');
                        system.debug(IdData);
                                         
                        Contact contactToUpdate = [
                            SELECT Id, TelecareId__c 
                            FROM Contact
                            WHERE Id = :contct.Id
                            LIMIT 1
                        ];
                        
                        if (contactToUpdate != null) {
                            contactToUpdate.TelecareId__c  = IdData;
                            update contactToUpdate;
                        }
                    }
                    
                    if(responseMap.get('status')==-1){
                        System.debug('POST request failed. Status code: ' + responseMap.get('status'));
                        System.debug('Response body: ' + response.getBody());
                         
                        //Telecare_Error_Log__c TELogs = ErrorRecord( response.getBody() );                            
                        //Insert TELogs;
                        
                        Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                     	HAFF_Logs.Status__c = 'Error';
                     	HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonPayload);
                     	HAFF_Logs.Record_Id__c = contct.Id;
                        telLog.add(HAFF_Logs);
                    }
                    else{
                   system.debug('The response was succesful');
                   system.debug(responseMap);
                   Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                   HAFF_Logs.Status__c = 'Success';
                   HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonPayload);
                   HAFF_Logs.Record_Id__c = contct.Id;
                   telLog.add(HAFF_Logs);
                }
    
                
                } else {
                // Error handling
                System.debug('POST request failed. Status code: ' + response.getStatusCode());
                System.debug('Response body: ' + response.getBody());

                throw new CalloutException(response.getBody());            
                
                }
            
        }
        
        if(!telLog.isEmpty())
        {
		Insert telLog;
        }
            
    }   
    
    
    // CALLOUT 
    Public HttpResponse Callout( TelecareJSONWrapperClass.ContactWrapper JsonPayload ){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String EndpointValue = getEndpoint.Value__c;
        
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(EndpointValue);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');           
            System.debug(JsonPayload);
            request.setBody(JSON.serializePretty(JsonPayload, false));
            request.setTimeout(60000);
            system.debug(request);
            
            HttpResponse response = http.send(request);
            Return response;
        
    }
    
    // CREATING ERROR RECORD 
    public Telecare_Error_Log__c ErrorRecord( String responseBody ){
        map<string, object> ErrorResponseMap =  (map<string, object>) Json.deserializeUntyped(responseBody);
        system.debug(ErrorResponseMap);
         
        Telecare_Error_Log__c TELogs = new Telecare_Error_Log__c();
        TELogs.Error_Message__c = (String)ErrorResponseMap.get('msg');
        TELogs.NPI_Number_Error__c = String.valueof(ErrorResponseMap.get('data'));
        TELogs.Status_Code__c = String.valueof(ErrorResponseMap.get('status'));
        TELogs.Description__c = responseBody;
        TELogs.NPI_Number_Error__c = (String)ErrorResponseMap.get('msg'); 
        TELogs.Record_Id__c = contct.Id; 
        
        return TELogs;
    }
        
        
  
    
    @TestVisible
    private list<TelecareJSONWrapperClass.ContactWrapper> generateContactJSON( list<Contact> contList ){
        
        list<TelecareJSONWrapperClass.ContactWrapper> ConDataInstanceList = new list<TelecareJSONWrapperClass.ContactWrapper>();
        
        for(contact con : contList){            
            ConDataInstanceList.add(generateContactJSONWrapper(con));                        
        }
        system.debug(ConDataInstanceList);
        return ConDataInstanceList;
    }
     
    @TestVisible
    private TelecareJSONWrapperClass.ContactWrapper generateContactJSONWrapper( Contact con ){

        TelecareJSONWrapperClass.ContactWrapper ConDataInstance = new TelecareJSONWrapperClass.ContactWrapper();
            
            ConDataInstance.sforce_id = con.Id;         
            ConDataInstance.Email = con.TS_Email__c;
            ConDataInstance.FirstName = con.FirstName;
            ConDataInstance.LastName = con.LastName;
            ConDataInstance.Gender = 'TestGender';
            ConDataInstance.NPINumber = con.NPI_Number__c;
            ConDataInstance.MobilePhone = con.MobilePhone;
            ConDataInstance.AddressBlock = 'Example'; //con.MailingStreet+ ' '+con.MailingCity+ ' '+con.MailingState+ ' '+con.MailingPostalCode+ ' '+con.MailingCountry;
            ConDataInstance.IsActive = con.Provider_Status__c == 'Active' ? True : False ;
            ConDataInstance.ContractDate = DateTime.now();
            ConDataInstance.SecretKey = SecretKey;
            system.debug(ConDataInstance);
        
            return ConDataInstance;
    }
    
        public Telecare_Integration_Log__c hosAffLogs( String responseBody ){
        map<string, object> ResponseMap =  (map<string, object>) Json.deserializeUntyped(responseBody);
        system.debug(ResponseMap);
         
        Telecare_Integration_Log__c HALogs = new Telecare_Integration_Log__c();
        HALogs.Message__c = (String)ResponseMap.get('msg');
        HALogs.Data__c = String.valueof(ResponseMap.get('data'));
        HALogs.Status_Code__c = String.valueof(ResponseMap.get('status'));
        HALogs.Response_Body__c = responseBody;
        HALogs.Object_Name__c = 'Contact';
        
        return HALogs;
    }
    
    
    
    
}