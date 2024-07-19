trigger TelecareIntegrationHospitalAffiliationTrigger on Hospital_Affiliation__c ( AFTER INSERT, AFTER UPDATE ) {

    
    Contact_Integration_Data__mdt ToggleTriggers = [Select id, DeveloperName, HosAffTriggToggleBox__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    Boolean HosAffOnOff = ToggleTriggers.HosAffTriggToggleBox__c;
    system.debug(HosAffOnOff);
    
    if(HosAffOnOff){
           Switch On Trigger.OperationType{
            
            WHEN AFTER_INSERT{
                
                list<Id> HosIds = new List<Id>();
                list<Id> ConIds = new List<Id>();
                
                system.debug(Trigger.new);
                for( Hospital_Affiliation__c HosAffNew : Trigger.new ){
                     HosIds.add(HosAffNew.Id);
                     ConIds.add(HosAffNew.Provider__c);
                }
    
                list<Hospital_Affiliation__c> HosAffLstSendable = new list<Hospital_Affiliation__c>();            
                map<id, Contact> ConEntMap = new Map<id, Contact>( [Select Id, TelecareId__c, Test_Record__c from Contact where Id in: ConIds] );
                system.debug(ConEntMap); 
                
                list<Hospital_Affiliation__c> HosAffLst = [Select Id, Provider__c, Affiliation_Status__c, Credentialing_Entity__c, Credentialing_Entity_Name__c, From__c, To__c ,Approval_Date__c
                                                           from Hospital_Affiliation__c 
                                                           where Id in: HosIds];
                system.debug(HosAffLst);
                
                for(Hospital_Affiliation__c HosAffNew : HosAffLst ){
                                  
                    Contact con = ConEntMap.get(HosAffNew.Provider__c);
                    system.debug(con);
                    //          
                    if(con != null && con.TelecareId__c!=Null && con.Test_Record__c != true  && HosAffNew.Credentialing_Entity__c != Null){
                       if(HosAffNew.From__c != Null && HosAffNew.To__c != Null){
                           
                               HosAffLstSendable.add(HosAffNew);
                               system.debug(HosAffLstSendable);                           
                               
                       }
                                             
                    }
                                                    
                }
                
                if(!HosAffLstSendable.isEmpty()){
                   TelecareIntegHosAffHandler.AFTER_INSERT( HosAffLstSendable,HosAffLstSendable[0]);  
                }
                
                
                
            }
            
            
            WHEN AFTER_UPDATE{
                
                list<Id> HosIds = new List<Id>();
                list<Id> ConIds = new List<Id>();
                
                for( Hospital_Affiliation__c HosAffNew : Trigger.new ){
                     HosIds.add(HosAffNew.Id);
                     ConIds.add(HosAffNew.Provider__c);
                }
    
                list<Hospital_Affiliation__c> HosAffLstSendable = new list<Hospital_Affiliation__c>();            
                map<id, Contact> ConEntMap = new Map<id, Contact>( [Select Id, TelecareId__c,Test_Record__c from Contact where Id in: ConIds] );
                system.debug(ConEntMap);            
                list<Hospital_Affiliation__c> HosAffLst = [Select Id, Provider__c, isChecked__c, Affiliation_Status__c, Credentialing_Entity_Name__c, Credentialing_Entity__c, From__c, To__c ,Approval_Date__c
                                                           from Hospital_Affiliation__c 
                                                           where Id in: HosIds];
                
                for(Hospital_Affiliation__c HosAffNew : HosAffLst ){
                    
                    Hospital_Affiliation__c HosAfOld = trigger.oldmap.get(HosAffNew.id);               
                    Contact con = ConEntMap.get(HosAffNew.Provider__c);
                    system.debug(con);
                    
                    //
                    if(con != null && con.TelecareId__c!=Null && con.Test_Record__c != true  && HosAffNew.Credentialing_Entity__c != Null && HosAffNew.From__c != Null && HosAffNew.To__c != Null){
                           
                            if( HosAffNew.Credentialing_Entity__c != HosAfOld.Credentialing_Entity__c || HosAffNew.From__c != HosAfOld.From__c || 
                            HosAffNew.To__c != HosAfOld.To__c || HosAffNew.Affiliation_Status__c != HosAfOld.Affiliation_Status__c
                            || HosAffNew.isChecked__c != HosAfOld.isChecked__c || HosAffNew.Approval_Date__c != HosAfOld.Approval_Date__c ){
                         
                            HosAffLstSendable.add(HosAffNew);
                            system.debug(HosAffLstSendable);                        
                            }                                                 
                        
                    }
                                                    
                }
                   
                if(!HosAffLstSendable.isEmpty()){
                   TelecareIntegHosAffHandler.AFTER_UPDATE( HosAffLstSendable,HosAffLstSendable[0] ); 
                }
                
                
            }
            
       
            
            
        } 
        
    }
    
    
    
       
    
    
    
    
    
}