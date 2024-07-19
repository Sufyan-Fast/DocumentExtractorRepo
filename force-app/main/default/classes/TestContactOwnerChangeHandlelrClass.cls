@istest
public class TestContactOwnerChangeHandlelrClass {
    
     @istest
    public static void testMethodupdateOwnerField(){
       list<Contact> phList = new list<Contact>();
        Account newobj = new Account(Name= 'Test', Territory__c = 'East');
        Insert newobj;
		for( integer i = 0; i < 10; i++)
		{
    	Contact ph = new Contact();
    	ph.LastName = 'Test' + i;
        ph.AccountId = newobj.Id;
    	phList.add(ph);
		}

       	test.starttest();
        Insert phList;
        test.stoptest();
    }

}