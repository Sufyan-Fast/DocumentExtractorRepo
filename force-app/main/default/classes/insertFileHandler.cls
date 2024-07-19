public class insertFileHandler {

    public static void getContactId( List<ContentVersion> newFiles ){
        list <id> recId = new list<id>();

    List<ContentDocumentLink> cDL = [SELECT ContentDocument.Id, ContentDocument.Title, Id, LinkedEntityId, LinkedEntity.Type 
    FROM ContentDocumentLink 
    WHERE ContentDocument.Id = :newFiles[0].ContentDocumentId];
 
      for (ContentDocumentLink link : cDL) {
       
        // if (link.LinkedEntity.Type == 'Contact' || link.LinkedEntity.Type == 'Hospital_Affiliation__c' || link.LinkedEntity.Type == 'License__c' || link.LinkedEntity.Type == 'Hospital_Privilege_Application__c' || link.LinkedEntity.Type == 'verifiable__WorkHistory__c' || link.LinkedEntity.Type == 'vfyLicensingMgr__LicenseApplication__c' || link.LinkedEntity.Type == 'DEA_Number__c' || link.LinkedEntity.Type == 'vfyLicensingMgr__LicenseApplication__c'  ) 
        //{
            if(link.LinkedEntity.Type != 'User' ){

                System.debug('link.LinkedEntity.Type'+link.LinkedEntity.Type);
                
                recId.add(link.LinkedEntityId);
            }
        
    }
    
    if (!recId.isEmpty() && !newFiles.isEmpty()) {
        
               sharePointController obj = new sharePointController(recId[0],newFiles[0] );
        	   system.enqueueJob(obj);
        		
}


    }
}