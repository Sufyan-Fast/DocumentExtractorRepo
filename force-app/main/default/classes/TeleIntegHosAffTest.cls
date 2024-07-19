@isTest
Private class TeleIntegHosAffTest {
    
    
    @isTest 
    Private static void HsoAffInsertTest(){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, HosAffTriggToggleBox__c,  Value__c, HosAffUpdateEndpoint__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String EndpointForUpdate = getEndpoint.HosAffUpdateEndpoint__c;
        String SecretKey = getEndpoint.Secret_Key__c;
        Boolean HosAffOnOff = getEndpoint.HosAffTriggToggleBox__c;
        
        String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        //String AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital' ).getRecordTypeId();
        
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        Acc.Territory__c = 'East';
       // Acc.RecordTypeId = AccRecTypeId;  
        Insert Acc;
        
        map<id, contact> ConEntMap = new map<id, contact>();
        
        Contact con = new Contact();
        con.LastName = 'TestContact2';
        con.AccountId = Acc.id;
        con.TS_Email__c = 'TestData2@gmail.com';
        con.MobilePhone = '8743091054';  
        con.NPI_Number__c = '8743091054';
        con.RecordTypeId = ConRecTypeId;
        con.TelecareId__c = '71e68b75-3ecf-4559-96f8-adc3a35129b6';
        Insert con;
        ConEntMap.put(con.id, con);
            
        
        Credentialing_Entity__c cred = new Credentialing_Entity__c();
        cred.Name = 'TestCred';
        Insert cred;
        
        List<Hospital_Affiliation__c> lstHosAff = new list<Hospital_Affiliation__c>();
        
        Hospital_Affiliation__c hos = new Hospital_Affiliation__c();
        hos.Provider__c = con.Id;
        hos.Credentialing_Entity__c = cred.id;
        hos.To__c = Date.today();
        hos.From__c = Date.today();
        hos.Affiliation_Status__c = 'Telemedicine';
        lstHosAff.add(hos);
        
        Insert lstHosAff;                       
        
        
        
        TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper HosAffUpdatedDataInstance = new TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper(); 
        
        HosAffUpdatedDataInstance.telercare_user_id = con.TelecareId__c;
        HosAffUpdatedDataInstance.salesforce_user_id = hos.Provider__c;
        HosAffUpdatedDataInstance.credentialing_entity = cred.Name; 
        HosAffUpdatedDataInstance.credentialing_entity_id = hos.Credentialing_Entity__c;
        HosAffUpdatedDataInstance.start_date = string.valueOf(hos.From__c);
        HosAffUpdatedDataInstance.end_date = string.valueOf(hos.To__c);  
        HosAffUpdatedDataInstance.SecretKey = SecretKey;
            
        String ResponseBody =  '{"telercare_user_id":"003DU00000goiDNYAY","SecretKey":"123456789","salesforce_user_id":"7430000054","credentialing_entity":"TestCred","credentialing_entity_id":"003DU00000goiDNYAY","end_date":"2024-09-04T11:38:29.641Z","start_date":"2023-09-04T11:38:29.641Z"}'; 
        
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.Class, new TeleIntegHosAffMockTest() );
        
       TelecareIntegHosAffUpdCallout HosAffCalloutinstance = new TelecareIntegHosAffUpdCallout( lstHosAff , lstHosAff[0]);
        HosAffCalloutinstance.generateHosAffJSON( lstHosAff );
        HosAffCalloutinstance.generateHosAffJSONWrapper( hos, ConEntMap  );
        
        HttpResponse response = HosAffCalloutinstance.Callout( HosAffUpdatedDataInstance );
        
        Test.stopTest();  
        
        System.assertEquals(200, response.getStatusCode(), 'The status code does not match');
        System.assertEquals(ResponseBody, response.getBody(), 'The supply JSON string does not match');
        
     
        
        
    }
    
    
    
    
    
    @isTest 
    Private static void HsoAffUpdateTest(){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, HosAffUpdateEndpoint__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String EndpointForUpdate = getEndpoint.HosAffUpdateEndpoint__c;
        String SecretKey = getEndpoint.Secret_Key__c;
        
        String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
       // String AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital' ).getRecordTypeId();
        
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        Acc.Territory__c = 'East';
       // Acc.RecordTypeId = AccRecTypeId;  
        Insert Acc;
        
        map<id, contact> ConEntMap = new map<id, contact>();
        
        Contact con = new Contact();
        con.LastName = 'TestContact2';
        con.AccountId = Acc.id;
        con.TS_Email__c = 'TestData2@gmail.com';
        con.MobilePhone = '8743091054';  
        con.NPI_Number__c = '8743091054';
        con.RecordTypeId = ConRecTypeId;
        con.TelecareId__c = '71e68b75-3ecf-4559-96f8-adc3a35129b6';
        Insert con;
        ConEntMap.put(con.id, con);
            
        
        Credentialing_Entity__c cred = new Credentialing_Entity__c();
        cred.Name = 'TestCred';
        Insert cred;
        
        List<Hospital_Affiliation__c> lstHosAff = new list<Hospital_Affiliation__c>();
        
        Hospital_Affiliation__c hos = new Hospital_Affiliation__c();
        hos.Provider__c = con.Id;
        hos.Credentialing_Entity__c = cred.id;
        hos.To__c = Date.today();
        hos.From__c = Date.today();
        hos.Affiliation_Status__c = 'Telemedicine';
        lstHosAff.add(hos);
        
        Insert lstHosAff;
               
        Date today = Date.today();
        Date tomorrow = today.addDays(1);

        hos.To__c = tomorrow;
        Update hos;
        
        
        
        TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper HosAffUpdatedDataInstance = new TelecareJSONWrapperClass.HospitalAffiliationUpdateWrapper(); 
        
        HosAffUpdatedDataInstance.telercare_user_id = con.TelecareId__c;
        HosAffUpdatedDataInstance.salesforce_user_id = hos.Provider__c;
        HosAffUpdatedDataInstance.credentialing_entity = cred.Name; 
        HosAffUpdatedDataInstance.credentialing_entity_id = hos.Credentialing_Entity__c;
        HosAffUpdatedDataInstance.start_date = string.valueOf(hos.From__c);
        HosAffUpdatedDataInstance.end_date = string.valueOf(hos.To__c);  
        HosAffUpdatedDataInstance.SecretKey = SecretKey;
            
        String ResponseBody =  '{"telercare_user_id":"003DU00000goiDNYAY","SecretKey":"123456789","salesforce_user_id":"7430000054","credentialing_entity":"TestCred","credentialing_entity_id":"003DU00000goiDNYAY","end_date":"2024-09-04T11:38:29.641Z","start_date":"2023-09-04T11:38:29.641Z"}'; 
        
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.Class, new TeleIntegHosAffMockTest() );
        
      TelecareIntegHosAffUpdCallout HosAffCalloutinstance = new TelecareIntegHosAffUpdCallout( lstHosAff, lstHosAff[0] );
        HosAffCalloutinstance.generateHosAffJSON( lstHosAff );
        HosAffCalloutinstance.generateHosAffJSONWrapper( hos, ConEntMap  );
        
        HttpResponse response = HosAffCalloutinstance.Callout( HosAffUpdatedDataInstance );
        
        Test.stopTest();  
        
        System.assertEquals(200, response.getStatusCode(), 'The status code does not match');
        System.assertEquals(ResponseBody, response.getBody(), 'The supply JSON string does not match');
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
  
    
    

}