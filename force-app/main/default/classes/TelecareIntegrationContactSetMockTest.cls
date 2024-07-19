@isTest
public with sharing class TelecareIntegrationContactSetMockTest {
    
    
    @isTest 
    public static void TestPostCalloutOnInsert(){
               
        Contact_Integration_Data__mdt getEndpoint = [Select id, DeveloperName, Value__c, ContactTriggToggleBox__c, Secret_Key__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
        String EndpointValue = getEndpoint.Value__c;
        Boolean ContOnOff = getEndpoint.ContactTriggToggleBox__c;
        
        String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        //string PhyRecTypeIdValue = '0125f000000AqEHAA0';
        
       // String AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital' ).getRecordTypeId();
        
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        Acc.Territory__c = 'East';
        ////Acc.RecordTypeId = AccRecTypeId; 
        Insert Acc;     
        
        list<Contact> ContList = new list<contact>();
        
        Contact con = new Contact();
        con.LastName = 'TestContact1';
        con.AccountId = Acc.id;
        con.TS_Email__c = 'TestData1@gmail.com';
        con.MobilePhone = '7430000054';  
        con.NPI_Number__c = '7430000054';
        con.RecordTypeId = ConRecTypeId;
        ContList.add(con);
        Insert ContList;
         
        TelecareJSONWrapperClass.ContactWrapper ConDataInstance = new TelecareJSONWrapperClass.ContactWrapper();           
        ConDataInstance.sforce_id = '003DU00000goiDNYAY';         
        ConDataInstance.Email = con.TS_Email__c;
        ConDataInstance.FirstName = con.LastName;
        ConDataInstance.LastName = con.LastName;
        ConDataInstance.Gender = 'TestGender';
        ConDataInstance.NPINumber = con.NPI_Number__c;
        ConDataInstance.MobilePhone = con.MobilePhone;
        ConDataInstance.AddressBlock = 'Example'; 
        ConDataInstance.IsActive = true;
        ConDataInstance.ContractDate = DateTime.now();
        ConDataInstance.SecretKey = '123456789';
        
        // To be given the response body to mock HttpCalloutMock
        String ResponseBody =  '{"sforce_id":"003DU00000goiDNYAY","SecretKey":"123456789","NPINumber":"7430000054","MobilePhone":"7430000054","LastName":"TestContact1","IsActive":true,"Gender":"TestGender","FirstName":"TestContact1","Email":"TestData1@gmail.com","ContractDate":"2023-10-04T12:35:40.523Z","AddressBlock":"Example"}';  
       
        // For creating Mock response For Error record 
        String Mockresponse = '{ "msg": "Request is not successful", "data": null, "status": -1 }';
        
        Test.startTest();  
        
        Test.setMock(HttpCalloutMock.class, new TelecareIntegrationContactTriggerTest());
        
        TelecareIntegrationContactTriggerCallout telecareCallIntnse = new TelecareIntegrationContactTriggerCallout( ContList, con );
        telecareCallIntnse.generateContactJSON( ContList );
        telecareCallIntnse.generateContactJSONWrapper( con );
        
        //Again creating the instance for the Queueable Class not removing it becaue it has been test and not want to remove anything from here. 
        TelecareIntegrationContactTriggerCallout TestSetMock = new TelecareIntegrationContactTriggerCallout( ContList, con );
        
        HttpResponse response = TestSetMock.Callout(ConDataInstance);
        
        telecareCallIntnse.ErrorRecord( Mockresponse );
        
        Test.stopTest();
        
        System.assertEquals(200, response.getStatusCode(), 'The status code does not match');
        System.assertEquals(ResponseBody, response.getBody(), 'The supply JSON string does not match');
        //System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
            
                    
    }
    
    

       

        


    
    
    @isTest 
    public static void TestPostCalloutOnUpdateTelecareIsNull(){

        String ResponseBody =  '{"sforce_id":"003DU00000goiDNYAY","SecretKey":"123456789","NPINumber":"7430000054","MobilePhone":"7430000054","LastName":"TestContact1","IsActive":true,"Gender":"TestGender","FirstName":"TestContact1","Email":"TestData1@gmail.com","ContractDate":"2023-10-04T12:35:40.523Z","AddressBlock":"Example"}';  
        
        String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
        //string PhyRecTypeIdValue = '0125f000000AqEHAA0';
        
        //String AccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital' ).getRecordTypeId();
        
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        Acc.Territory__c = 'East';
        ////Acc.RecordTypeId = AccRecTypeId;  
        insert Acc;
        
        list<Contact> ContList = new list<contact>();
        
        Contact con = new Contact();
        con.LastName = 'TestContact2';
        con.AccountId = Acc.id;
        con.TS_Email__c = 'TestData2@gmail.com';
        con.MobilePhone = '8743091054';  
        con.NPI_Number__c = '8743091054';
        con.RecordTypeId = ConRecTypeId;
        Insert con;
        
        con.TelecareId__c = 'b9fd7e3a-fa87-48b9-a43a-75ee66e1c5e6'; 
        con.TS_Email__c = 'TestDataUpdate@gmail.com';
        con.LastName = 'UpdatedName';
        Update con;
        
        ContList.add(con);
        
        TelecareJSONWrapperClass.UpdateContactWrapper ConDataInstance = new TelecareJSONWrapperClass.UpdateContactWrapper();           
        ConDataInstance.sforce_id = '003DU00000goiDNYAY';         
        ConDataInstance.Email = con.TS_Email__c;
        ConDataInstance.FirstName = con.LastName;
        ConDataInstance.LastName = con.LastName;
        ConDataInstance.NPINumber = con.NPI_Number__c;
        ConDataInstance.MobilePhone = con.MobilePhone;
        ConDataInstance.AddressBlock = 'Example'; 
        ConDataInstance.SecretKey = '123456789';
               
        
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.Class, new TelecareIntegrationContactTriggerTest() );
        
        TelecareIntegrationContactUpdatedCallout UpdateInstance = new TelecareIntegrationContactUpdatedCallout( ContList, con);
        UpdateInstance.generateContactJSON( ContList );
        UpdateInstance.generateContactJSONWrapper( con );
        
        HttpResponse response = UpdateInstance.Callout( ConDataInstance );
        
        Test.stopTest();  
        
        System.assertEquals(200, response.getStatusCode(), 'The status code does not match');
        System.assertEquals(ResponseBody, response.getBody(), 'The supply JSON string does not match');
        
        
        
    }
    
    
  
    
    
    
    
}