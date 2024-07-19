trigger TelecareIntegrationContactTrigger on Contact (AFTER INSERT, AFTER UPDATE) {
    
    
    Contact_Integration_Data__mdt ToggleTriggers = [Select id, DeveloperName, ContactTriggToggleBox__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    Boolean ContOnOff = ToggleTriggers.ContactTriggToggleBox__c;
    system.debug(ContOnOff);
    
    //For Owner Update 
    //Starts->
    Physician_Assignement__mdt ToggleTrigger = [Select id, DeveloperName, PhysicianIsActive__c From Physician_Assignement__mdt where DeveloperName = 'IsActiveTrigger' ];
    Boolean PhysicianIsActive = ToggleTrigger.PhysicianIsActive__c;
    system.debug(PhysicianIsActive);
    
    if(PhysicianIsActive){
        
         Switch On Trigger.OperationType{
        
            WHEN AFTER_INSERT{
                                                  
                   ContactOwnerChangeHandlelrClass.updateOwnerField(Trigger.newmap);
         
                 
            }
        }
        
    }
    
    //end
    
    if(ContOnOff){
        
       String ConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Physician').getRecordTypeId();
   
        Switch On Trigger.OperationType{
            
            When AFTER_INSERT{
                
                list<Contact> ContList = new list<Contact>();
                
                For(Contact con : Trigger.new){
                    System.debug('checkbox=>' + con.Test_Record__c);
                    if( con.RecordTypeId == ConRecTypeId && con.TS_Email__c != Null && con.Test_Record__c != true){
                        ContList.add(con);
                    }
                }
                
                if (!ContList.isEmpty()){
                   TelecareIntegrationContactTriggerHandler.AFTER_INSERT( ContList, ContList[0] );
             
                }  
                
            }
            
            When AFTER_UPDATE{
                
                // For Update Call
                list<Contact> ContListUpdated = new list<Contact>();
                
                For(Contact con : Trigger.new){
                    contact OldCon = Trigger.OldMap.get(con.id);
                     System.debug('checkbox=>' + con.Test_Record__c);
                    if( con.RecordTypeId == ConRecTypeId && con.TelecareId__c != Null && con.Test_Record__c != true){
                        if( con.TS_Email__c != OldCon.TS_Email__c || con.MobilePhone != OldCon.MobilePhone || con.NPI_Number__c != OldCon.NPI_Number__c || con.LastName != OldCon.LastName ){
                             
                            ContListUpdated.add(con);
                        }                       
                    }
                }
                
                if (!ContListUpdated.isEmpty()){ 
                   TelecareIntegrationContactTriggerHandler.AFTER_UPDATE( ContListUpdated, ContListUpdated[0] );             
                }  
                
                
                //For Insert Call Again if telecare Id is not there                      
                list<Contact> ContList = new list<Contact>();
                
                For(Contact con : Trigger.new){
                     System.debug('checkbox=>' + con.Test_Record__c);
                    if( con.RecordTypeId == ConRecTypeId && con.TelecareId__c == Null && con.Test_Record__c != true){
                        ContList.add(con);
                    }
                }
                
                if (!ContList.isEmpty()){
                   TelecareIntegrationContactTriggerHandler.AFTER_INSERT( ContList, ContList[0] );
             
                }                                 
                
            }
            
        } 
        
        
        
        
        
        
    }             
    
    
}