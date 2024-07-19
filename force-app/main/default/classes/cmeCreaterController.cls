public with sharing class cmeCreaterController {



    
                @AuraEnabled  
                public static string saveContact(CME__c cmeRec, string file, string fileName) {
                  string cmeRecId;  
                  try{  
                    Insert cmeRec;  
                    cmeRecId = cmeRec.Id;  
                    String base64File = EncodingUtil.urlDecode(file, 'UTF-8');     
                    ContentVersion contentVersionRec = new ContentVersion();  
                    contentVersionRec.Title = fileName;  
                    contentVersionRec.PathOnClient = '/' + fileName;  
                    contentVersionRec.FirstPublishLocationId = cmeRec.Id;  
                    contentVersionRec.VersionData = EncodingUtil.base64Decode(base64File);  
                    contentVersionRec.IsMajorVersion = true;  
                    Insert contentVersionRec;  
                  } catch(Exception ex){  
                    system.debug('Exception===>'+ex.getMessage());  
                  }  
                  return cmeRecId;  
                }    
             
    
    
    
    
        
    



}