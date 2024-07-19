@isTest
public class InvokedByContentNoteFlowTest {
    @isTest
    public static void testContentNoteCreation() {

        List<Hospital_Privilege_Application__c> hospitalApps = new List<Hospital_Privilege_Application__c>();
        for (Integer i = 0; i < 3; i++) {
            Hospital_Privilege_Application__c app = new Hospital_Privilege_Application__c();
            //app.username__c = 'App' + i;
            
            app.OwnerId = UserInfo.getUserId();
            
            hospitalApps.add(app);
        }
        insert hospitalApps;

        InvokedByContentNoteFLow.ContentNoteInput input = new InvokedByContentNoteFLow.ContentNoteInput();
        input.NameScreen = 'TestName';
        input.ContentScreen = 'TestContent';
        input.HospitalPrivilegeApplications = hospitalApps;

        Test.startTest();
        InvokedByContentNoteFLow.ContentNoteCreation(new List<InvokedByContentNoteFLow.ContentNoteInput>{input});
        Test.stopTest();

        hospitalApps = [SELECT Latest_Notes__c FROM Hospital_Privilege_Application__c WHERE Id IN :hospitalApps];
        for (Hospital_Privilege_Application__c app : hospitalApps) {
            System.assertEquals('TestName', app.Latest_Notes__c);
        }

        Set<Id> hospitalAppIds = new Set<Id>();
        for (Hospital_Privilege_Application__c app : hospitalApps) {
            hospitalAppIds.add(app.Id);
        }

        List<ContentDocumentLink> contentDocumentLinks = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :hospitalAppIds];
        System.assertEquals(hospitalApps.size(), contentDocumentLinks.size());

    }

}