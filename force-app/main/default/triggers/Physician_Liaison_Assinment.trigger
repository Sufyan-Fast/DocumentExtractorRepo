trigger Physician_Liaison_Assinment on Physician_Liaison__c ( AFTER INSERT ) {
    
    Physician_Assignement__mdt ToggleTrigger = [Select id, DeveloperName, PhysicianIsActive__c From Physician_Assignement__mdt where DeveloperName = 'IsActiveTrigger' ];
    Boolean PhysicianIsActive = ToggleTrigger.PhysicianIsActive__c;
    system.debug(PhysicianIsActive);
    
    if(PhysicianIsActive){
        
         Switch On Trigger.OperationType{
        
            WHEN AFTER_INSERT{
                                                  
                  Physician_Liaison_Assinment_Handler.afterInsert(Trigger.newmap); 
         
                 
            }
        }
        
    }
       
   
}