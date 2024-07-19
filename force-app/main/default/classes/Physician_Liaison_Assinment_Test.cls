@istest
public class Physician_Liaison_Assinment_Test {

    @istest
    public static void testMethodAfterInsert(){
       Physician_Assignement__mdt ToggleTrigger = [Select id, DeveloperName, PhysicianIsActive__c From Physician_Assignement__mdt where DeveloperName = 'IsActiveTrigger' ];
       Boolean PhysicianIsActive = ToggleTrigger.PhysicianIsActive__c;
       list<Physician_Liaison__c> phList = new list<Physician_Liaison__c>();
		for( integer i = 0; i < 10; i++)
		{
    	Physician_Liaison__c ph = new Physician_Liaison__c();
    	ph.Last_Name__c = 'Test' + i;
    	phList.add(ph);
		}

       	test.starttest();
        Insert phList;
        test.stoptest();
    }
}