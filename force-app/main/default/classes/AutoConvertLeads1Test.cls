@isTest
public class AutoConvertLeads1Test {
    
    @istest
    public static void test(){
        integer total = AutoConvertLeads1.sum( 1, 2 );
        system.assertEquals( 3, total, 'The Assertion for sum is failed');
    }
          
      /*    
      static testMethod void createnewlead () {
          
       RecEventProdInactive__c cs = new RecEventProdInactive__c();
        cs.name = 'CheckActiveForTrigger';
        cs.isActive__c = true; 
        insert cs;   
          
      User userToCreate = [Select id from user where profile.Name ='System Administrator' AND IsActive = TRUE Limit 1];

      Test.startTest();
      Lead leadToCreate = new Lead();
      List<Id> Ids = New List<Id>();
      leadToCreate.ownerid = userToCreate.id;
      leadToCreate.LastName ='Khan';
      leadToCreate.Company ='Salesforce';
      leadToCreate.LeadSource ='Partner Referral';
      leadToCreate.Rating ='';
      leadToCreate.Status ='';
      insert leadToCreate;

      List< AutoConvertLeads1.Requests>  requests = new List<AutoConvertLeads1.Requests >();
      AutoConvertLeads1.Requests request = new AutoConvertLeads1.Requests ();
      request.LeadId = leadToCreate.id;
      requests.add (request);

      AutoConvertLeads1.LeadAssign(requests);

      Test.stopTest ();
          
		//
		List<Lead> checkLeadStatus = [SELECT id,Name,Status From Lead Where Id=:leadToCreate.Id];
          System.assertEquals('Converted', checkLeadStatus[0].status);
          
   }
          */
          
}