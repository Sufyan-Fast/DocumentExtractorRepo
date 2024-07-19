public class TelecareIntegrationContactUpdatedCallout implements Queueable, Database.AllowsCallouts {

    protected list<contact> contList;
    protected contact contct;
    
    Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, Update_Endpoint_Value__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    protected Final String EndpointForUpdate = getEndpoint.Update_Endpoint_Value__c;
    protected Final String SecretKey = getEndpoint.Secret_Key__c;
    
    public TelecareIntegrationContactUpdatedCallout( list<Contact> contList, contact contct ){
        
        this.contList = contList;
        this.contct = contct;
    }
    
    
    
     
    public void execute( QueueableContext QContext ){
         list<Telecare_Integration_Log__c> telLog = new list<Telecare_Integration_Log__c>();
        list<TelecareJSONWrapperClass.UpdateContactWrapper> ContactPayload = generateContactJSON( contList );
        system.debug(ContactPayload);
        
        for(TelecareJSONWrapperClass.UpdateContactWrapper JsonUpdatedPayload : ContactPayload){
            
            HttpResponse response = Callout( JsonUpdatedPayload );
            system.debug(response);
            
                if (response.getStatusCode() == 200) {
                    // Response handling
                    System.debug('POST request successful. Response: ' + response.getBody());
                    
                    map<string, object> responseMap =  (map<string, object>) Json.deserializeUntyped(response.getBody());
                    system.debug(responseMap);
                    
                    if(responseMap.get('status')==-1){
                        System.debug('POST request failed. Status code: ' + responseMap.get('status'));
                        System.debug('Response body: ' + response.getBody());
                         
                        
                        Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                     	HAFF_Logs.Status__c = 'Error';
                     	HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonUpdatedPayload);
                     	HAFF_Logs.Record_Id__c = contct.Id;
                        telLog.add(HAFF_Logs);
                    }
                    else{
                   system.debug('The response was succesful');
                   system.debug(responseMap);
                   Telecare_Integration_Log__c HAFF_Logs = hosAffLogs( response.getBody() ); 
                   HAFF_Logs.Status__c = 'Success';
                   HAFF_Logs.Http_Request_JSON__c = String.valueof(JsonUpdatedPayload);
                   HAFF_Logs.Record_Id__c = contct.Id;
                   telLog.add(HAFF_Logs);
                }
                }    
        }
        
           if(!telLog.isEmpty())
        {
		Insert telLog;
        }
            
        
    }
    
    
    // CALLOUT 
    Public HttpResponse Callout( TelecareJSONWrapperClass.UpdateContactWrapper JsonUpdatedPayload ){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, Update_Endpoint_Value__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String EndpointValue = getEndpoint.Update_Endpoint_Value__c;
        
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(EndpointValue);
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
    private list<TelecareJSONWrapperClass.UpdateContactWrapper> generateContactJSON( list<Contact> contList ){
        
        list<TelecareJSONWrapperClass.UpdateContactWrapper> ConDataUpdatedInstanceList = new list<TelecareJSONWrapperClass.UpdateContactWrapper>();
        
        for(contact con : contList){            
            ConDataUpdatedInstanceList.add(generateContactJSONWrapper(con));                        
        }
        system.debug(ConDataUpdatedInstanceList);
        return ConDataUpdatedInstanceList;
    }
     
    @TestVisible
    private TelecareJSONWrapperClass.UpdateContactWrapper generateContactJSONWrapper( Contact con ){

        TelecareJSONWrapperClass.UpdateContactWrapper ConUpdatedDataInstance = new TelecareJSONWrapperClass.UpdateContactWrapper();
                    
            ConUpdatedDataInstance.Id = con.TelecareId__c;
            ConUpdatedDataInstance.Email = con.TS_Email__c;
            ConUpdatedDataInstance.FirstName = con.FirstName;
            ConUpdatedDataInstance.LastName = con.LastName;
            ConUpdatedDataInstance.NPINumber = con.NPI_Number__c;
            ConUpdatedDataInstance.MobilePhone = con.MobilePhone;
            ConUpdatedDataInstance.AddressBlock = 'Example'; //con.MailingStreet+ ' '+con.MailingCity+ ' '+con.MailingState+ ' '+con.MailingPostalCode+ ' '+con.MailingCountry;
            ConUpdatedDataInstance.IsActive = con.Provider_Status__c == 'Active' ? True : False ;
            ConUpdatedDataInstance.sforce_id = con.id;
            ConUpdatedDataInstance.SecretKey = SecretKey;
            system.debug(ConUpdatedDataInstance);
        
            return ConUpdatedDataInstance;
    }

    public Telecare_Integration_Log__c hosAffLogs( String responseBody ){
        map<string, object> ResponseMap =  (map<string, object>) Json.deserializeUntyped(responseBody);
        system.debug(ResponseMap);
         
        Telecare_Integration_Log__c HALogs = new Telecare_Integration_Log__c();
        HALogs.Message__c = (String)ResponseMap.get('msg');
        HALogs.Data__c = String.valueof(ResponseMap.get('data'));
        HALogs.Status_Code__c = String.valueof(ResponseMap.get('status'));
        HALogs.Response_Body__c = responseBody; 
        
        return HALogs;
    }
    
    
    
    
}