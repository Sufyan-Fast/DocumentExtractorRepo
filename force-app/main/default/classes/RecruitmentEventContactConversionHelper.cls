public class RecruitmentEventContactConversionHelper {

    
        
            
    // REafterUpdate Method
    public static void REafterUpdate( set<id> recEventId ) {
        string accountId;
        string userId;
     	 // Getting the 'TeleSpecialists, LLC' Account Id    
        Account accountName = [Select Name FROM Account WHERE Name = 'TeleSpecialists, LLC' Limit 1 ];
        if(accountName != null){
            accountId = accountName.Id;  
        }

        user getUserId = [select id from user where name ='Christa Johnson'];
        if(getUserId != null){
            userId = getUserId.Id;  
        }      
        
        // The List of Recruitment_Event__c That are updated to Signed contract Date       
        list<Recruitment_Event__c> recUpdatedList = [ SELECT Id, LastName__c, FirstName__c, PSA_Options__c, Salutation__c, Specialty__c, Email__c, MobilePhone__c, Lead__c, Signed_Contract_Date__c, Offered_Date__c  FROM Recruitment_Event__c WHERE Id IN: recEventId ];        
            
            
        List<Lead> updatedLeads = new list<Lead>();
        
        List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
        list<Recruitment_Event__c> recEvIdStatuses = new list<Recruitment_Event__c>();
        
        
        //Queries for content document transfer.
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Hiding_Sections__c, Referrer__c FROM Lead WHERE Id IN (SELECT Lead__c FROM Recruitment_Event__c WHERE Id IN :recUpdatedList)]);
        // Video link to resolve the error below = https://www.youtube.com/watch?v=7ngN_MWF_Bo              
        Set<Id> contentDocIdList = leadMap.keySet();
            
        List<ContentDocumentLink> contentDocLinksList = [ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Lead WHERE id in : contentDocIdList ) ];       
        Map<Id, List<ContentDocumentLink>> contentDocumentLinksMap = new Map<Id, List<ContentDocumentLink>>();

        for ( ContentDocumentLink contentDocumentLink : contentDocLinksList ) {
            if (!contentDocumentLinksMap.containsKey(contentDocumentLink.LinkedEntityId)) {
                contentDocumentLinksMap.put(contentDocumentLink.LinkedEntityId, new List<ContentDocumentLink>());
            }
            contentDocumentLinksMap.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink);
        }
        
        
            
        // Map for Physician_Contract__c to store all Physician_Contract__c in recUpdatedList, 
        // This record was created when offerred date gets populated in recuitment event.  
        List <Physician_Contract__c> phyConlist = [ Select id, Contract_Signed_Date__c, Restrict_PsaOption_ToChange__c, PSA_Options__c, ContactId__c, Recruitment_EventId__c From Physician_Contract__c Where Recruitment_EventId__c  in: recUpdatedList ];
        
            Map <id, List<Physician_Contract__c> >  phyConMap = New Map <id, List<Physician_Contract__c> >();            
            For (Physician_Contract__c pC : phyConlist) {
                if( !phyConMap.containsKey(pC.Recruitment_EventId__c) ){
                phyConMap.put( pC.Recruitment_EventId__c, new List<Physician_Contract__c>() );
                }
                phyConMap.get(pC.Recruitment_EventId__c).add(pC);
            }   
        List <Physician_Contract__c> phyConlistUpdated = new List <Physician_Contract__c>();  
        
        // The Shift_Retention_Orientation__c that will be created from Each Recruitment_Event__c when signed contract date is populated. 
        List <Shift_Retention_Orientation__c> shRetenlist = new List <Shift_Retention_Orientation__c>();

        // The Physician_Liaison__c that will be created from Each Recruitment_Event__c when signed contract date is populated.   
        list<Physician_Liaison__c> phyLia = new list<Physician_Liaison__c>();    

        
        // The contacts List that will add the contact created from Each Recruitment_Event__c when signed contract date is populated.    
        list<Contact> conList = new list<Contact>();      
        // Getting the Physician RecordTypeId
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId(); 
        
        
        // Main loop to run over Every recruitment Event record
        for(Recruitment_Event__c recEvId : recUpdatedList){
            //Updating the recEvId Status to converted. 
            recEvId.Recruitment_Event_Status__c = 'Converted'; 
            recEvIdStatuses.add(recEvId);
            // New Contact Creation when the signed Contract Date is Not Null
            Contact con = new Contact();
            con.RecordTypeId = contactRecordTypeId; 
            con.accountId = accountId;
            con.RecruitmentEventId__c = recEvId.id;
            con.LastName = recEvId.LastName__c;  
            con.FirstName = recEvId.FirstName__c;
            con.Salutation = recEvId.Salutation__c;
            con.MobilePhone = recEvId.MobilePhone__c;
            con.Email = recEvId.Email__c;
            con.Signed_Contract_Date__c = recEvId.Signed_Contract_Date__c;
            con.Offered_Date__c = recEvId.Offered_Date__c;
            con.Specialty__c = recEvId.Specialty__c;  
            con.OwnerId = userId;
            //conList.add(con);
            // Inserting of physician liaison and adding it to a list and outside inserting the list. 
            Physician_Liaison__c phy = new Physician_Liaison__c();
            phy.First_Name__c = recEvId.FirstName__c;
            phy.Last_Name__c = recEvId.LastName__c;            
            phy.Signed_Contract_Date__c = recEvId.Signed_Contract_Date__c;
            phy.RecruitmentEventId__c = recEvId.id;
            phyLia.add(phy);

            // Creation of shift retention and orientation record and adding to a list and outcide inserting the list. 
            Shift_Retention_Orientation__c sFR = new Shift_Retention_Orientation__c();
            sFR.Physician_Status__c = 'Pending IC';
            sFR.First_Name__c = recEvId.FirstName__c;
            sFR.Last_Name__c = recEvId.LastName__c;
            sFR.PSA_Options__c = recEvId.PSA_Options__c;
            sFR.Specialty__c = recEvId.Specialty__c;
            sFR.Recruitment_EventId__c = recEvId.id;   
            sFR.Signed_Contract_Date__c = recEvId.Signed_Contract_Date__c;
            shRetenlist.add(sFR);
            
            
            // Updating the Physician_Contract__c Contract_Signed_Date__c Field and Contactid field will be updated after the contact gets inserted outside the loop            
            List< Physician_Contract__c > pHyCont = phyConMap.get(recEvId.id);
            if(pHyCont != null){
                for(Physician_Contract__c pCont : pHyCont){
                    pCont.Contract_Signed_Date__c = recEvId.Signed_Contract_Date__c;
                    //pCont.PSA_Options__c = recEvId.PSA_Options__c;  
                    pCont.Physician_Contract_Status__c = 'Activated';
                    phyConlistUpdated.add(pCont);
                }
            }
                                                                
            
            // Get Lead and its ContentDocuments
            Lead leadRecord = leadMap.get(recEvId.Lead__c);
            
            if( leadRecord != null && leadRecord.Referrer__c != null ){
            con.Referrer__c =  leadRecord.Referrer__c;
            }else{
            con.Referrer__c = ''; 
            }
            conList.add(con); 
            system.debug(conList.size());
            leadRecord.Hiding_Sections__c = True;            
            leadRecord.Status = 'Converted';                                  
            updatedLeads.add(leadRecord);
            
            //Creating links for files in lead to assign them later to contact 
            
            
                List<ContentDocumentLink> leadContentDocumentLinks = contentDocumentLinksMap.get(leadRecord.Id);
                if (leadContentDocumentLinks != null) {
                    for (ContentDocumentLink contentDocumentLink : leadContentDocumentLinks) {
                        ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                        newContentDocumentLink.ContentDocumentId = contentDocumentLink.ContentDocumentId;
                        newContentDocumentLink.LinkedEntityId = con.Id;
                        newContentDocumentLink.ShareType = 'V';
                        contentDocumentLinksToInsert.add(newContentDocumentLink);
                    }
                }                                                                                               
        }

            List<Database.SaveResult> contactInsertResults = Database.INSERT(conList); 
            List<Id> convertedContactIds = new List<Id>();    
            for (Database.SaveResult result : contactInsertResults) {
                if (result.isSuccess()) {
                convertedContactIds.add(result.getId());
            } else {
                System.debug('Error inserting contact: ' + result.getErrors()[0].getMessage());
            }
            }
            
        
            
        UPDATE recEvIdStatuses;                
        if(!updatedLeads.isEmpty()){
           UPDATE updatedLeads;  
        }               
        UPDATE phyConlistUpdated;          
        INSERT phyLia;
        INSERT shRetenlist;
        
                    
        if (!contentDocumentLinksToInsert.isEmpty()) {
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinksToInsert) {
                contentDocumentLink.LinkedEntityId = conList[0].Id; // Assigning LinkedEntityId
            }
            insert contentDocumentLinksToInsert;
        }
            
            
            
        // Updating the physician Contract ContactId field 
        List <Physician_Contract__c> phyConlistUpdatedContact = new List <Physician_Contract__c>();    
    
            if(!phyConlistUpdated.isEmpty())  {
                for( Physician_Contract__c phyCon : phyConlistUpdated ) {
                     phyCon.ContactId__c = conList[0].Id;
                     phyCon.Restrict_PsaOption_ToChange__c = True;
                     phyConlistUpdatedContact.add(phyCon);
                }
                UPDATE phyConlistUpdatedContact;
                
            }  
        

        // Updating the Shift_Retention_Orientation__c ContactId field 
        List <Shift_Retention_Orientation__c> updateShifRetContactId = new List <Shift_Retention_Orientation__c>();    

            if(!shRetenlist.isEmpty())  {
                for( Shift_Retention_Orientation__c sR : shRetenlist ) {
                     sR.ContactId__c = conList[0].Id;                     
                     updateShifRetContactId.add(sR);
                }

                UPDATE updateShifRetContactId;

            } 



        // Updating the physician Liason Contactid field
        List <Physician_Liaison__c> updatePhyLiasonContactId = new List <Physician_Liaison__c>();    

            if(!phyLia.isEmpty())  {
                for( Physician_Liaison__c phyL : phyLia ) {
                phyL.ContactId__c = conList[0].Id;                     
                updatePhyLiasonContactId.add(phyL);
                }
                
                UPDATE updatePhyLiasonContactId;

            } 
        
        
        
    }    
    
    
    
    
    
    
    
    /*
    // REBeforeUpdate Method
    public static void REBeforeUpdate( list<Recruitment_Event__c> recEventTriggerNew ) {
    
         List<Lead> AllLeads = [SELECT Id, Hiding_Sections__c FROM Lead]; 
            System.debug('AllLeads size: ' + AllLeads.size());
            Set<Id> UpdatedHidSecLeads = new Set<Id>();      
            for( Recruitment_Event__c recEventNew : recEventTriggerNew ){
                    for (Lead lead : AllLeads) {
                        if (lead.Id == recEventNew.Lead__c && lead.Hiding_Sections__c == True) {
                                                        
                            UpdatedHidSecLeads.add(lead.Id);
                             
                        }
                    }            
                                      
            }
            
            
           // list<Lead> LeadsRestricted = [ Select Id From lead WHERE Id IN : UpdatedHidSecLeads ];
        
            List<Recruitment_Event__c> RecEventRstd = [ SELECT Id, Lead__c FROM Recruitment_Event__c WHERE Lead__c IN : UpdatedHidSecLeads ];
            List<String> errors = new List<String>();
            
           
            

            for ( Recruitment_Event__c R : RecEventRstd ) {
                 // Throw an error if someone tries to update the record
                 errors.add('Some recruitment event has already been converted to Physician Contact for this lead. Therefore, you cannot Update any Recruitment event related to this lead anymore. ');
                // System.debug('RO: ' + errors);
                
            } 
         
            if (!errors.isEmpty()) {
            recEventTriggerNew[0].addError(errors[0]);
           }
        
    }

    */


    
     // REBeforeUpdate Method
    public static void REBeforeUpdate(List<Recruitment_Event__c> recEventTriggerNew) {
        // Collect Lead IDs from the Recruitment_Event__c records
        Set<Id> leadIds = new Set<Id>();
        for (Recruitment_Event__c recEvent : recEventTriggerNew) {
            if (recEvent.Lead__c != null) {
                leadIds.add(recEvent.Lead__c);
            }
        }
    
        // Query only the Leads associated with the recruitment events in the trigger
        Map<Id, Lead> leadsMap = new Map<Id, Lead>([SELECT Id, Hiding_Sections__c FROM Lead WHERE Id IN :leadIds]);
    
        // Set to store IDs of leads that have Hiding_Sections__c set to True
        Set<Id> updatedHidSecLeads = new Set<Id>();
    
        // Loop through the recruitment events and check the related leads
        for (Recruitment_Event__c recEvent : recEventTriggerNew) {
            Lead lead = leadsMap.get(recEvent.Lead__c);
            if (lead != null && lead.Hiding_Sections__c) {
                updatedHidSecLeads.add(lead.Id);
            }
        }
    
        // Query restricted Recruitment_Event__c records
        List<Recruitment_Event__c> recEventRstd = [SELECT Id, Lead__c FROM Recruitment_Event__c WHERE Lead__c IN :updatedHidSecLeads];
    
        // Map to store errors by record ID
        Map<Id, String> errors = new Map<Id, String>();
    
        // Loop through the restricted Recruitment_Event__c records and prepare errors
        for (Recruitment_Event__c recEvent : recEventRstd) {
            errors.put(recEvent.Id, 'Some recruitment event has already been converted to Physician Contact for this lead. Therefore, you cannot update any recruitment event related to this lead anymore.');
        }
    
        // Add errors to the respective Recruitment_Event__c records in the trigger
        for (Recruitment_Event__c recEvent : recEventTriggerNew) {
            if (errors.containsKey(recEvent.Id)) {
                recEvent.addError(errors.get(recEvent.Id));
            }
        }
    }
    
    
    
    
    
     
    /*
    // REBeforeInsert Method
    public static void REBeforeInsert( list<Recruitment_Event__c> newRecruitmentEvents ) {
        
           List<Lead> allLeads = [SELECT Id, Hiding_Sections__c FROM Lead];
        System.debug('AllLeads size: ' + allLeads.size());
        Set<Id> updatedHidSecLeads = new Set<Id>();
        
        for (Recruitment_Event__c recEventNew : newRecruitmentEvents) {
            for (Lead lead : allLeads) {
                if (lead.Id == recEventNew.Lead__c && lead.Hiding_Sections__c) {
                    updatedHidSecLeads.add(lead.Id);
                }
            }
        }
        
        //List<Lead> leadsRestricted = [SELECT Id FROM Lead WHERE Id IN :updatedHidSecLeads];
        List<Recruitment_Event__c> recEventRestricted = [SELECT Id, Lead__c FROM Recruitment_Event__c WHERE Lead__c IN :updatedHidSecLeads];
        List<String> errors = new List<String>();

        for (Recruitment_Event__c recEvent : recEventRestricted) {
            // Throw an error if someone tries to update the record
            errors.add('Some recruitment event has already been converted to Physician Contact for this lead. Therefore, you cannot update any Recruitment event related to this lead anymore.');
            System.debug('RO: ' + errors);
        }

        if (!errors.isEmpty()) {
            newRecruitmentEvents[0].addError(errors[0]);
        }
    }
    */


    
 // REBeforeInsert Method
    public static void REBeforeInsert(List<Recruitment_Event__c> newRecruitmentEvents) {
        // Collect Lead IDs from the Recruitment_Event__c records
        Set<Id> leadIds = new Set<Id>();
        for (Recruitment_Event__c recEvent : newRecruitmentEvents) {
            if (recEvent.Lead__c != null) {
                leadIds.add(recEvent.Lead__c);
            }
        }
    
        // Query only the Leads associated with the recruitment events in the trigger
        Map<Id, Lead> leadsMap = new Map<Id, Lead>([SELECT Id, Hiding_Sections__c FROM Lead WHERE Id IN :leadIds]);
    
        // Set to store IDs of leads that have Hiding_Sections__c set to True
        Set<Id> updatedHidSecLeads = new Set<Id>();
    
        // Loop through the recruitment events and check the related leads
        for (Recruitment_Event__c recEvent : newRecruitmentEvents) {
            Lead lead = leadsMap.get(recEvent.Lead__c);
            if (lead != null && lead.Hiding_Sections__c) {
                updatedHidSecLeads.add(lead.Id);
            }
        }
    
        // Query restricted Recruitment_Event__c records
        List<Recruitment_Event__c> recEventRestricted = [SELECT Id, Lead__c FROM Recruitment_Event__c WHERE Lead__c IN :updatedHidSecLeads];
    
        // Map to store errors by record ID
        Map<Id, String> errors = new Map<Id, String>();
    
        // Loop through the restricted Recruitment_Event__c records and prepare errors
        for (Recruitment_Event__c recEvent : recEventRestricted) {
            errors.put(recEvent.Id, 'Some recruitment event has already been converted to Physician Contact for this lead. Therefore, you cannot insert any recruitment event related to this lead anymore.');
        }
    
        // Add errors to the respective Recruitment_Event__c records in the trigger
        for (Recruitment_Event__c recEvent : newRecruitmentEvents) {
            if (errors.containsKey(recEvent.Id)) {
                recEvent.addError(errors.get(recEvent.Id));
            }
        }
    }
    




 }