trigger RecruitmentEventContactConversion on Recruitment_Event__c ( BEFORE INSERT, AFTER INSERT, BEFORE UPDATE, AFTER UPDATE, BEFORE DELETE, AFTER DELETE, AFTER UNDELETE ) {      
    map<string, RecEventProdInactive__c> checkActive = RecEventProdInactive__c.getAll();    
    if(checkActive.get('CheckActiveForContactConversion').isActive__c){
        switch on Trigger.OperationType  {

            when BEFORE_INSERT
            {
                RecruitmentEventContactConversionHelper.REBeforeInsert( trigger.new );

            }
            when AFTER_UPDATE{
                  // Code to Get the IDs of those Recruitment events that needs to be Converted to Physician contact. 
            Set<Id> recEventId = new Set<Id>();              
            for( Recruitment_Event__c recEventNew : trigger.new )
            {
                
                Recruitment_Event__c recEventOld = trigger.oldmap.get(recEventNew.id);
                if( recEventOld.Signed_Contract_Date__c == null && recEventNew.Signed_Contract_Date__c != null && recEventNew.Recruitment_Event_Status__c != 'Converted' )
                { 
                recEventId.add(recEventNew.Id);   
                }           
                
            }
            RecruitmentEventContactConversionHelper.REafterUpdate(recEventId); 
            }

            when BEFORE_UPDATE{
                RecruitmentEventContactConversionHelper.REBeforeUpdate(trigger.new );
            }


        }
            
                /*   
        if(trigger.isAfter && trigger.isUpdate) {   
            
            // Code to Get the IDs of those Recruitment events that needs to be Converted to Physician contact. 
            Set<Id> recEventId = new Set<Id>();              
            for( Recruitment_Event__c recEventNew : trigger.new )
            {
                
                Recruitment_Event__c recEventOld = trigger.oldmap.get(recEventNew.id);
                if( recEventOld.Signed_Contract_Date__c == null && recEventNew.Signed_Contract_Date__c != null && recEventNew.Recruitment_Event_Status__c != 'Converted' )
                { 
                   recEventId.add(recEventNew.Id);   
                }           
                
            }
         
            RecruitmentEventContactConversionHelper.REafterUpdate(recEventId); 
            
            
        }
          */
        /*
        if (Trigger.isBefore && Trigger.isUpdate ) {
        
            RecruitmentEventContactConversionHelper.REBeforeUpdate(trigger.new );
                                        
        }  
*/
    /*
        if (Trigger.isBefore && Trigger.isInsert) {
            RecruitmentEventContactConversionHelper.REBeforeInsert( trigger.new );
            
            
             //Note that the addError() method can only be called on records in the 
             //Trigger.new list during a before insert trigger event, which is why we're adding the error to the first record in the list.
    }
          */

    
    }
}