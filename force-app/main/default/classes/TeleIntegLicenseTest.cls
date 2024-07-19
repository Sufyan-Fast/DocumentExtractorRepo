@isTest
public class TeleIntegLicenseTest {
    
    @isTest
    public static void After_Insert(){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, LicenTriggToggleBox__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String SecretKey = getEndpoint.Secret_Key__c;
        Boolean LicenOnOff = getEndpoint.LicenTriggToggleBox__c;
        
        String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        //String AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital' ).getRecordTypeId();
        
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        Acc.Territory__c = 'East';
       // Acc.RecordTypeId = AccRecTypeId;  
        Insert Acc;
        
        
        map<id, contact> ContMap = new map<id, contact>();        
        Contact con = new Contact();
        con.LastName = 'TestContact2';
        con.AccountId = Acc.id;
        con.TS_Email__c = 'TestData2@gmail.com';
        con.MobilePhone = '8743091054';  
        con.NPI_Number__c = '8743091054';
        con.RecordTypeId = ConRecTypeId;
        con.TelecareId__c = '71e68b75-3ecf-4559-96f8-adc3a35129b6';
        Insert con;
        ContMap.put(con.id, con);
            
        
        Credentialing_Entity__c cred = new Credentialing_Entity__c();
        cred.Name = 'TestCred';
        Insert cred;
        
        List<License__c> LicenseLst = new list<License__c>();
        License__c lic = new License__c();
        lic.Provider__c = con.id;
        lic.License_Number__c = '4353400';
        lic.License_Type_ID__c = 'a1yDU0000049jGwYAI';
        lic.License_Type__c = 'Doctor of Osteopathy';
        lic.Issue_Date__c = Date.today();
        lic.Expiration_Date__c = Date.today();
        lic.In_Use__c = True;
        lic.Jurisdiction_State_picklist__c = 'SC' ;
        LicenseLst.add(lic);
        Insert LicenseLst;
        
        TelecareJSONWrapperClass.ProviderLicenseInformation licWrapperInstance = new TelecareJSONWrapperClass.ProviderLicenseInformation();
        
        licWrapperInstance.telecare_user_id = con.TelecareId__c;
        licWrapperInstance.salesforce_user_id = con.Id;
        licWrapperInstance.license_number = lic.License_Number__c;
        licWrapperInstance.license_type_id = lic.License_Type_ID__c;
        licWrapperInstance.license_type_name = lic.License_Type__c;
        licWrapperInstance.issued_date = string.valueof(lic.Issue_Date__c);
        licWrapperInstance.expired_date = string.valueof(lic.Expiration_Date__c);
        licWrapperInstance.is_active = string.valueof(lic.In_Use__c);
        licWrapperInstance.license_state = string.valueof(lic.Jurisdiction_State_picklist__c);
        licWrapperInstance.SecretKey = SecretKey;
        
        
        
        String ResponseBody = '{ "telercare_user_id ":"e9e119e4-d96c-4108-a984-25f79c837e0e","salesforce_user_id":"003DU00000h3RM8YAM","license_number ":"4353400","license_type_id":"a1yDU0000049jGwYAI","license_type_name":"Doctor of Osteopathy","is_active":"True","license_state ":"GA", "expired_date":"2024-09-04T11:38:29.641Z", "issued_date":"2024-09-04T11:38:29.641Z","SecretKey":"123456789" }'; 
        
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.Class, new TeleIntegHosAffMockTest() );
        
        TelecareIntegLicenseCallout LicenseCalloutinstance = new TelecareIntegLicenseCallout( LicenseLst, ContMap,LicenseLst[0] );
        LicenseCalloutinstance.generateHosAffJSON( LicenseLst );
        LicenseCalloutinstance.generateHosAffJSONWrapper( lic );
        
        HttpResponse response = LicenseCalloutinstance.Callout( licWrapperInstance );
        
        Test.stopTest();  
        
        System.assertEquals(200, response.getStatusCode(), 'The status code does not match');
        //System.assertEquals(ResponseBody, response.getBody(), 'The supply JSON string does not match');
        
        
    }
    
    
    
    
    
    @isTest
    public static void After_Update(){
        
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String SecretKey = getEndpoint.Secret_Key__c;
        
        String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        //String AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital' ).getRecordTypeId();
        
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        Acc.Territory__c = 'East';
      //  Acc.RecordTypeId = AccRecTypeId;  
        Insert Acc;
        
        
        map<id, contact> ContMap = new map<id, contact>();        
        Contact con = new Contact();
        con.LastName = 'TestContact2';
        con.AccountId = Acc.id;
        con.TS_Email__c = 'TestData2@gmail.com';
        con.MobilePhone = '8743091054';  
        con.NPI_Number__c = '8743091054';
        con.RecordTypeId = ConRecTypeId;
        con.TelecareId__c = '71e68b75-3ecf-4559-96f8-adc3a35129b6';
        Insert con;
        ContMap.put(con.id, con);
            
        
        Credentialing_Entity__c cred = new Credentialing_Entity__c();
        cred.Name = 'TestCred';
        Insert cred;
        
        List<License__c> LicenseLst = new list<License__c>();
        License__c lic = new License__c();
        lic.Provider__c = con.id;
        lic.License_Number__c = '4353400';
        lic.License_Type_ID__c = 'a1yDU0000049jGwYAI';
        lic.License_Type__c = 'Doctor of Osteopathy';
        lic.Issue_Date__c = Date.today();
        lic.Expiration_Date__c = Date.today();
        lic.In_Use__c = True;
        lic.Jurisdiction_State_picklist__c = 'SC' ;
        LicenseLst.add(lic);
        Insert LicenseLst;
                
        lic.Issue_Date__c = Date.today() + 2;
        Update lic;

        
        TelecareJSONWrapperClass.ProviderLicenseInformation licWrapperInstance = new TelecareJSONWrapperClass.ProviderLicenseInformation();
        
        licWrapperInstance.telecare_user_id = con.TelecareId__c;
        licWrapperInstance.salesforce_user_id = con.Id;
        licWrapperInstance.license_number = lic.License_Number__c;
        licWrapperInstance.license_type_id = lic.License_Type_ID__c;
        licWrapperInstance.license_type_name = lic.License_Type__c;
        licWrapperInstance.issued_date = string.valueof(lic.Issue_Date__c);
        licWrapperInstance.expired_date = string.valueof(lic.Expiration_Date__c);
        licWrapperInstance.is_active = string.valueof(lic.In_Use__c);
        licWrapperInstance.license_state = string.valueof(lic.Jurisdiction_State_picklist__c);
        licWrapperInstance.SecretKey = SecretKey;
        
        
        
        String ResponseBody = '{ "telercare_user_id ":"e9e119e4-d96c-4108-a984-25f79c837e0e","salesforce_user_id":"003DU00000h3RM8YAM","license_number ":"4353400","license_type_id":"a1yDU0000049jGwYAI","license_type_name":"Doctor of Osteopathy","is_active":"True","license_state ":"GA", "expired_date":"2024-09-04T11:38:29.641Z", "issued_date":"2024-09-04T11:38:29.641Z","SecretKey":"123456789" }'; 
        
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.Class, new TeleIntegHosAffMockTest() );
        
        TelecareIntegLicenseCallout LicenseCalloutinstance = new TelecareIntegLicenseCallout( LicenseLst, ContMap,LicenseLst[0] );
        LicenseCalloutinstance.generateHosAffJSON( LicenseLst );
        LicenseCalloutinstance.generateHosAffJSONWrapper( lic );
        
        HttpResponse response = LicenseCalloutinstance.Callout( licWrapperInstance );
        
        Test.stopTest();  
        
        System.assertEquals(200, response.getStatusCode(), 'The status code does not match');
        //System.assertEquals(ResponseBody, response.getBody(), 'The supply JSON string does not match');
        
                
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
}