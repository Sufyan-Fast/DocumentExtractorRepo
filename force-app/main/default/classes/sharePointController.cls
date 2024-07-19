public class sharePointController implements Queueable, Database.AllowsCallouts{
    
    public Id conObj;
    public ContentVersion CVobj;
  // public static String azureAppName = 'Authorization';
    public static final String Drive_Id = Label.Share_point_Drive_Id;
    public static final String Site_Id = Label.Share_Point_Site_Id;
    public static final String tele_Drive_Id = Label.TeleSpecialits_Drive_Id;
    public static final String tele_Site_Id = Label.TeleSpecialits_Site_Id;    
       
   public  sharePointController(Id con , ContentVersion cv)
   {
       this.conObj = con;
       this.CVobj = cv;
   }
       
   public void execute( QueueableContext QContext ){
        //getAccessToken('Authorization',conObj, CVobj);
        getAccessToken('TeleSpecialits_Site',conObj, CVobj);
   }
   
  
    public static void getAccessToken(String azureAppName, Id conObj, ContentVersion cv ) { 
        String access_token;
       Azure_App__mdt azureAuth = getAzureAppDetails(azureAppName)[0];
       Http h = new Http();
       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
       req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       req.setEndpoint('https://login.microsoftonline.com/'+
       EncodingUtil.urlEncode(azureAuth.Tenant_Id__c, 'UTF-8').replaceAll('\\+', '%20')+'/oauth2/token');
       String body = 	'grant_type=' + azureAuth.Azure_Grant_Type__c 	+
       '&client_id=' + EncodingUtil.urlEncode(azureAuth.Client_Id__c, 'UTF-8') +
       '&client_secret='+ EncodingUtil.urlEncode(azureAuth.Client_Secret__c, 'UTF-8') +
       '&resource='+ azureAuth.Azure_Scope__c	;
       req.setBody(body);
       HttpResponse res = h.send(req);
       if(res.getStatusCode() == 200){
           Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 
           access_token = String.valueOf(resMap.get('access_token'));
           System.debug('access_token=>' + access_token);
           if(access_token !=NULL)
           {
               String pathName = getContactName(conObj);
               System.debug('pathName'+pathName);
               if(pathName != null){

                   createFolderAndFile(access_token, tele_Drive_Id, cv, pathName , conObj);                
                }
           }
   }
}
   
public static String getContactName(Id conId) {

    String sObjName = conId.getSObjectType().getDescribe().getName();
    try{

      System.debug('sObjName'+sObjName);
        

    // Dynamically construct the SOQL query string
    String query = 'SELECT Id, CB_Folder__c FROM ' + sObjName + ' WHERE Id = :conId';
    
    // Execute the SOQL query
    SObject result = Database.query(query);
    
    // Check if the result is not null and contains the CB_Folder__c field
    if (result != null && result.get('CB_Folder__c') != null) {
        // Return the value of CB_Folder__c
        System.debug('result cb folder'+result.get('CB_Folder__c'));
        return (String)result.get('CB_Folder__c');
    } else {
        System.debug('in null'+null);

        return null; 
    }
}
 catch (QueryException e) {
    // Handle the exception
    System.debug('Query exception occurred: ' + e.getMessage());
    return null;
 
}


}

   
   
    public static List<Azure_App__mdt> getAzureAppDetails(String azureApp)
   { 
       string query = 'SELECT ' + 'Id, DeveloperName, client_Id__c, Client_Secret__c, Azure_Scope__c,'
       + 'Tenant_Id__c, Azure_Grant_Type__c, SharePoint_Site_Id__c '+
       'FROM Azure_App__mdt'; 
       if(!String.isBlank(azureApp)){ 
        query += ' WHERE DeveloperName =:azureApp'; 
        }
       return Database.query(String.escapeSingleQuotes(query));
}
   
      public static void createFolderAndFile(String acc_tok, String DriveId,ContentVersion cv, String folderName , Id conObj)
           {
           System.debug('folderName=>' + folderName);
            string fileName;
            string contentLength;
            blob formBlob;
            System.debug('Callout Log 1:' + cv);
            if(cv !=NULL)     
            {
            Contentversion cvobj = [select id, title, ContentDocumentId, FileExtension, versionData from contentversion where Id = : cv.Id limit 1];
            fileName = cvobj.title;
             if(cvobj.FileExtension!=null && cvobj.FileExtension!='')
             {
                  fileName = fileName + '.' + cvobj.FileExtension;  
              }         
             System.debug('Callout Log 2:' + fileName);
   
     //callout ePOR service
             string contentType = EinsteinVision_HttpBodyPart.GetContentType();
   /*
     //  Compose the form
             string form64 = '';
     //******This was the boundary I was missing****
             form64 += EinsteinVision_HttpBodyPart.WriteBoundary();
             form64 += EinsteinVision_HttpBodyPart.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(cvobj.versionData), fileName);   
             formBlob = EncodingUtil.base64Decode(form64);
             contentLength = string.valueOf(formBlob.size());
   
             System.debug('Callout Log 3:' + formBlob.size());
   
             if(formBlob.size()>12000000)
             {
                  //throw new CustomException('File size limit is 12 MBytes');
                  System.debug('File size limit is 12 MBytes');
             }
     else
     {

*/
           String endPoint = 'https://graph.microsoft.com/v1.0/drives/' + 
                               EncodingUtil.urlEncode(DriveId, 'UTF-8').replaceAll('\\+', '%20') +
                               '/root:/'+EncodingUtil.urlEncode(folderName, 'UTF-8').replaceAll('\\+', '%20')+'/'+
                               EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '%20')+':/content';

           Http h = new Http();
           HttpRequest req = new HttpRequest();
           req.setMethod('PUT');
           req.setHeader('Authorization', 'Bearer '+ acc_tok);
           //req.setHeader('Content-Type', 'text/plain');
           //req.setHeader('Content-Length', contentLength);
           req.setHeader('Content-Type', contentType);
           req.setHeader('Accept', 'application/json');
           req.setEndpoint(endPoint);
           //req.setBodyAsBlob(formBlob);
             req.setBodyAsBlob(cvobj.versionData);
           HttpResponse res = h.send(req);
           System.debug('Response Body: ' + res.getBody());
           // Parse JSON response
           Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
           
           // Extract download URL
           String downloadUrl = (String) responseBodyMap.get('@microsoft.graph.downloadUrl');
           
           System.debug('Download URL: ' + downloadUrl);
           



           contact cont = [Select Id, FirstName, LastName, Sharepoin_URL__c from Contact where Id =:conObj LIMIT 1];
           System.debug('con'+cont);
           
 			if(String.isBlank(cont.Sharepoin_URL__c))
            {
                String cmbName = cont.FirstName + ' ' + cont.LastName;
                cont.Sharepoin_URL__c = 'https://mytelespecialists.sharepoint.com/sites/Test2SalesforceIntegration/Documents/Forms/AllItems.aspx?viewpath=%2Fsites%2FTest2SalesforceIntegration%2FDocuments%2FForms%2FAllItems%2Easpx&id=%2Fsites%2FTest2SalesforceIntegration%2FDocuments%2FProviders%2F'
                   + EncodingUtil.urlEncode(cmbName, 'UTF-8').replaceAll('\\+', '%20');
                System.debug('cont=>' + cont);
                update cont;
            }
    // }
    }

   }
}