trigger TelecareIntegrationLicenseTrigger on License__c ( AFTER INSERT, AFTER UPDATE ) {

    Contact_Integration_Data__mdt ToggleTriggers = [Select id, DeveloperName, LicenTriggToggleBox__c From Contact_Integration_Data__mdt where DeveloperName = 'Endpoint' ];
    Boolean LicenOnOff = ToggleTriggers.LicenTriggToggleBox__c;
    system.debug(LicenOnOff);
    
    if(LicenOnOff){
           Switch On Trigger.OperationType{
            
            
            When AFTER_INSERT{
                
                list<License__c> LicLst = Trigger.new;
                
                set<Id> ContIds = new set<Id>();            
                
                for(License__c lic : LicLst){
                    ContIds.add(lic.Provider__c);              
                }
                
                //Map for Contact and  to get them where needed 
                map<Id, Contact> ContMap = new Map<Id, Contact>( [SELECT Id, TelecareId__c,Test_Record__c 
                                                                  FROM Contact 
                                                                  WHERE Id in: ContIds] );
    
                                                               
                // LIST TO TARGET ENDPOINT 
                list<License__c> SendableLicLst = new list<License__c>();
    
                for(License__c lic : LicLst ){
                    Contact con = !ContMap.isEmpty() ? ContMap.get(lic.Provider__c) : new contact();                                                  
                    if( con.TelecareId__c != Null && con.Test_Record__c != true && lic.Provider__c != Null   ){
                        system.debug(lic);
                        SendableLicLst.add(lic);
                    }
                     
                }
                
                if(!SendableLicLst.isEmpty()){
                    TelecareIntegLicenseHandler.AFTER_INSERT_UPDATE(SendableLicLst, ContMap,SendableLicLst[0]);
                }
                
                
                
                
            }
    
    
    
    
            
            When AFTER_UPDATE{
                
                list<License__c> LicLst = Trigger.new;
                
                set<Id> ContIds = new set<Id>();            
                
                for(License__c lic : LicLst){
                    ContIds.add(lic.Provider__c);              
                }
                
                //Map for Contact and  to get them where needed 
                map<Id, Contact> ContMap = new Map<Id, Contact>( [SELECT Id, TelecareId__c , Test_Record__c
                                                                  FROM Contact 
                                                                  WHERE Id in: ContIds] );
    
                                                               
                // LIST TO TARGET ENDPOINT 
                list<License__c> SendableLicLst = new list<License__c>();
    
                for(License__c lic : LicLst ){
                    Contact con = !ContMap.isEmpty() ? ContMap.get(lic.Provider__c) : new contact();                                                  
                    if( con.TelecareId__c != Null && con.Test_Record__c != true && lic.Provider__c != Null   ){
                        system.debug(lic);
                        SendableLicLst.add(lic);
                    }
                     
                }
                
                if(!SendableLicLst.isEmpty()){
                    TelecareIntegLicenseHandler.AFTER_INSERT_UPDATE(SendableLicLst, ContMap,SendableLicLst[0]);
                }
                
              
                 
            }
            
            
            
        } 
        
    }


    
    
    
    
    
    
}