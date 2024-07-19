public class InvokedByContentNoteFLow {

    @InvocableMethod(label='Create Content Note' description='Creates Content Notes for Hospital_Privilege_Application__c records')
      public static void ContentNoteCreation(List<ContentNoteInput> inputList) {
        if (inputList != null && !inputList.isEmpty()) {
          
            List<Hospital_Privilege_Application__c> lsttoupdateHS = new List<Hospital_Privilege_Application__c>();
            List<Hospital_Privilege_Application__c> HosPrAppsList = inputList[0].HospitalPrivilegeApplications;
    
            if (HosPrAppsList != null) {
                List<Id> hosIds = new List<Id>();
                List<ContentNote> ContList = new List<ContentNote>();
                
                Map<Id, ContentNote> HosToContentNoteMap = new Map<Id, ContentNote>();
                for (Hospital_Privilege_Application__c HosPriApp : HosPrAppsList) {
                    
                    ContentNote note = new ContentNote();
                    
                    note.Title = inputList[0].NameScreen;
                    note.Content = Blob.valueOf(inputList[0].ContentScreen);
                    
                    note.OwnerId = HosPriApp.OwnerId; 
                    HosPriApp.Latest_Notes__c = inputList[0].NameScreen;
                    ContList.add(note);
                    hosIds.add(HosPriApp.Id);
                    HosToContentNoteMap.put(HosPriApp.Id, note);
                    lsttoupdateHS.add(HosPriApp);
                    
                }
                
                insert ContList;
                update lsttoupdateHS;

                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    
                for (Id recordId : HosToContentNoteMap.keySet()) {
                    ContentNote contentNote = HosToContentNoteMap.get(recordId);
                    
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = recordId;
                    cdl.ContentDocumentId = contentNote.Id;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
    
                    cdlList.add(cdl);
                }
    
                insert cdlList; 
            }
        }
    }


    public class ContentNoteInput {
        @InvocableVariable(label='Name Screen Value' description='Value from Name Screen Input')
        public String NameScreen;

        @InvocableVariable(label='Content Screen Value' description='Value from Content Screen Input')
        public String ContentScreen;

        @InvocableVariable(label='Hospital Privilege Applications' description='List of Hospital Privilege Application records')
        public List<Hospital_Privilege_Application__c> HospitalPrivilegeApplications;
    }
}