public class TestSharePointIntegration {
    
     public static String access_token;
   // public static String azureAppName = 'Authorization';
     public static final String Drive_Id = Label.Share_point_Drive_Id;
     public static final String Site_Id = Label.Share_Point_Site_Id;
     public static final String tele_Drive_Id = Label.TeleSpecialits_Drive_Id;
     public static final String tele_Site_Id = Label.TeleSpecialits_Site_Id;
    
    public static void runAllFunctions(String docId)
    {
        access_token = getAccessToken('Authorization');
        System.debug('access_token=>' + access_token);
        //getDriveId(access_token,tele_Site_Id);
        //createFolder(access_token, tele_Drive_Id, Site_Id);
        //createFolderAndFile(access_token, Drive_Id, docId);
        //getPreviewUrl(access_token,tele_Drive_Id);
        createPublicLink(access_token,Drive_Id);
    }
    
    public static String getAccessToken(String azureAppName) { 
        if(string.isBlank(access_token)){
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
		'&resource='+ azureAuth.Azure_Scope__c;
		req.setBody(body);
		HttpResponse res = h.send(req);
		if(res.getStatusCode() == 200){
			Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 
            access_token = String.valueOf(resMap.get('access_token'));
		}
	}
		return access_token;
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
    
    public static void getDriveId (String acc_tok, String SiId)
    {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer '+ acc_tok);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setEndpoint('https://graph.microsoft.com/v1.0/sites/' + SiId +'/drives');
		HttpResponse res = h.send(req);
		System.debug('Response Body: ' + res.getBody());
        //Account obj = new Account(Name = 'test APi', Territory__c = 'East');
        //obj.testing__c = res.getBody();
        //Insert obj;
    }
    
     public static void getPreviewUrl (String acc_tok, String DriveId)
    {
        String endpoint = 'https://mytelespecialists.sharepoint.com' + 
							+ '/_api/web/lists/getbytitle(Documents)/items?$select=*,FileLeafRef,FileRef';
        //String endpoint = 'https://mytelespecialists.sharepoint.com' + 
						//	+ '/_api/web/lists/getbytitle(Documents)/fields';
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer '+ acc_tok);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		//req.setEndpoint('https://mytelespecialists.sharepoint.com/sites/Test2SalesforceIntegration/_api/web/lists/getbytitle(' + 'Documents' + ')/items?$select=*,FileLeafRef,FileRef');
		req.setEndpoint(endpoint);
		HttpResponse res = h.send(req);
		System.debug('Response Body: ' + res.getBody());
        //Account obj = new Account(Name = 'test APi', Territory__c = 'East');
        //obj.testing__c = res.getBody();
        //Insert obj;
    }
    
    public static void createFolder(String acc_tok, String DriveId, String SiteId)
    {
        String FolderId;
        //String drId = 'b!8y8zBtoQSEC1IDrX_85g5VZwazQ6sptCtDkQzTnp5nhZy_5C4FldSrrIpWgBokqY';
        String folderBody = '{"name": "Test Folder","folder": { },"@microsoft.graph.conflictBehavior": "rename"}';
		string endPoint = 'https://graph.microsoft.com/v1.0/drives/' + 
                          EncodingUtil.urlEncode(DriveId, 'UTF-8').replaceAll('\\+', '%20') +
                          '/root/children';
       // String endPoint = 'https://graph.microsoft.com/v1.0/sites/'+SiteId+'/drives/'+ DriveId + '/root';
        //String endPoint = 'https://graph.microsoft.com/v1.0/drives/'+ DriveId + '/root/children';
        //String endpoint = 'https://graph.microsoft.com/v1.0/sites/' + SiteId + '/drives/'+DriveId+'/root:/Manually Created:/children';
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer '+ acc_tok);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setEndpoint(endPoint);
		req.setBody(folderBody);
		HttpResponse res = h.send(req);
		System.debug('Response Body: ' + res.getBody());
        //Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 
        //FolderId = String.valueOf(resMap.get('id'));
        //System.debug('FolderId=>' + FolderId);
        
    }
    
    public static void createFolderAndFile(String acc_tok, String DriveId,String idStr)
    {
     string fileName;
     string contentLength;
     blob formBlob;
     String boundary = '----------------------------741e90d31eff';
     List<contentversion> cvList = new List<contentversion>();
     cvList = [select id, title, ContentDocumentId, FileExtension, versionData from contentversion where ContentDocumentId = :idStr limit 1];
     System.debug('Callout Log 1:' + cvList);
     if(!cvList.isEmpty())     
     {
      //form fileName with cv ID
      fileName = cvList[0].title;
      if(cvList[0].FileExtension!=null && cvList[0].FileExtension!='')
      {
       fileName = fileName + '.' + cvList[0].FileExtension;  
      }         
      System.debug('Callout Log 2:' + fileName);
    
      //callout ePOR service
      string contentType = EinsteinVision_HttpBodyPart.GetContentType();
    
      //  Compose the form
      string form64 = '';
      //******This was the boundary I was missing****
      form64 += EinsteinVision_HttpBodyPart.WriteBoundary();
      form64 += EinsteinVision_HttpBodyPart.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(cvList[0].versionData), fileName);
    
      formBlob = EncodingUtil.base64Decode(form64);
      contentLength = string.valueOf(formBlob.size());
    
      System.debug('Callout Log 3:' + formBlob.size());
    
      if(formBlob.size()>12000000)
      {
       //this a "public class CustomException extends Exception{}"
       //throw new CustomException('File size limit is 12 MBytes');
       System.debug('File size limit is 12 MBytes');
      }
      else
      {
        String folderName = 'Doc Folder';
			//String fileBody = 'Hello World!';
			///String fileName = 'Combine Document1.txt';
			String endPoint = 'https://graph.microsoft.com/v1.0/drives/' + 
                                EncodingUtil.urlEncode(DriveId, 'UTF-8').replaceAll('\\+', '%20') +
                                '/root:/'+EncodingUtil.urlEncode(folderName, 'UTF-8').replaceAll('\\+', '%20')+'/'+
                                EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '%20')+':/content';
          
			
          Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setMethod('PUT');
			req.setHeader('Authorization', 'Bearer '+ acc_tok);
			//req.setHeader('Content-Type', 'text/plain');contentType
			req.setHeader('Content-Length', contentLength);
			req.setHeader('Content-Type', contentType);
			//req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
			req.setHeader('Accept', 'application/json');
			req.setEndpoint(endPoint);
			//req.setBodyAsBlob(formBlob);
			//blob filedata = uploadFile(cvList[0].versionData,fileName);
			req.setBodyAsBlob(cvList[0].versionData);
			HttpResponse res = h.send(req);
			System.debug('Response Body: ' + res.getBody());
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 
        	String FolderId = String.valueOf(resMap.get('id'));
        	System.debug('FolderId=>' + FolderId);

    
      }
     }
 
    }
    
    public static void createPublicLink(String acc_tok, String DriveId)
    {
		String FolderId;
        //String drId = 'b!8y8zBtoQSEC1IDrX_85g5VZwazQ6sptCtDkQzTnp5nhZy_5C4FldSrrIpWgBokqY';
        String folderBody = '{"type": "edit","scope": "organization"}';
		string endPoint = 'https://graph.microsoft.com/v1.0/drives/' + 
                                EncodingUtil.urlEncode(DriveId, 'UTF-8').replaceAll('\\+', '%20') +'/items/'+
                                EncodingUtil.urlEncode('01CE5X3BQCOWOOHVPWMFAYHRBK5YYH4MMS', 'UTF-8').replaceAll('\\+', '%20')+'/createLink';
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer '+ acc_tok);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setEndpoint(endPoint);
		req.setBody(folderBody);
		HttpResponse res = h.send(req);
		System.debug('Response Body: ' + res.getBody());
        Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 
       FolderId = String.valueOf(resMap.get('link'));
        System.debug('FolderId=>' + FolderId);
        
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'Sharepoint Doc';
		conVer.ContentLocation = 'E';
		conVer.PathOnClient = 'https://myhawklogix.sharepoint.com/Shared%20Documents/Doc%20Folder/1683191472828.jpeg?csf=1&web=1&e=IKR28A&cid=ee016428-0806-4e81-8670-33ed180257f4';
		conVer.IsMajorVersion = true;
        //conVer.ContentUrl = 'https://myhawklogix.sharepoint.com/Shared%20Documents/Doc%20Folder/1683191472828.jpeg?csf=1&web=1&e=IKR28A&cid=ee016428-0806-4e81-8670-33ed180257f4';
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = '003TH000007DLLyYAO';
		conDocLink.ContentDocumentId = conDoc;
		conDocLink.shareType = 'V';
		conDocLink.Visibility='AllUsers';
		insert conDocLink;
        
    }
    
    public static blob uploadFile(Blob file_body, String file_name){
      // Repost of code  with fix for file corruption issue
      // Orignal code postings and explanations
      // http://enreeco.blogspot.in/2013/01/salesforce-apex-post-mutipartform-data.html
      // http://salesforce.stackexchange.com/questions/24108/post-multipart-without-base64-encoding-the-body
      // Additional changes commented GW: that fix issue with occasional corruption of files
      String boundary = '----------------------------741e90d31eff';
      String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
      // GW: Do not prepend footer with \r\n, you'll see why in a moment
      // String footer = '\r\n--'+boundary+'--'; 
      String footer = '--'+boundary+'--';             
      String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
      while(headerEncoded.endsWith('='))
      {
       header+=' ';
       headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
      }
      String bodyEncoded = EncodingUtil.base64Encode(file_body);
      // GW: Do not encode footer yet
      // String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
 
      Blob bodyBlob = null;
      String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
 
      // GW: Replacing this entire section
      /*
      if(last4Bytes.endsWith('='))
      {
           Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
           HttpRequest tmp = new HttpRequest();
           tmp.setBodyAsBlob(decoded4Bytes);
           String last4BytesFooter = tmp.getBody()+footer;   
           bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
      }
      else
      {
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
      }
      */
     // GW: replacement section to get rid of padding without corrupting data
     if(last4Bytes.endsWith('==')) {
        // The '==' sequence indicates that the last group contained only one 8 bit byte
        // 8 digit binary representation of CR is 00001101
        // 8 digit binary representation of LF is 00001010
        // Stitch them together and then from the right split them into 6 bit chunks
        // 0000110100001010 becomes 0000 110100 001010
        // Note the first 4 bits 0000 are identical to the padding used to encode the
        // second original 6 bit chunk, this is handy it means we can hard code the response in
        // The decimal values of 110100 001010 are 52 10
        // The base64 mapping values of 52 10 are 0 K
        // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
        // Therefore, we replace == with 0K
        // Note: if using \n\n instead of \r\n replace == with 'oK'
        last4Bytes = last4Bytes.substring(0,2) + '0K';
        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
        // We have appended the \r\n to the Blob, so leave footer as it is.
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
      } else if(last4Bytes.endsWith('=')) {
        // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
        // We replace final 8 bit byte with a CR e.g. \r
        // 8 digit binary representation of CR is 00001101
        // Ignore the first 2 bits of 00 001101 they have already been used up as padding
        // for the existing data.
        // The Decimal value of 001101 is 13
        // The base64 value of 13 is N
        // Therefore, we replace = with N
        // Note: if using \n instead of \r replace = with 'K'
        last4Bytes = last4Bytes.substring(0,3) + 'N';
        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
        // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
        footer = '\n' + footer;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
      } else {
        // Prepend the CR LF to the footer
        footer = '\r\n' + footer;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
      }
 
      //HttpRequest req = new HttpRequest();
      //req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
      //req.setMethod('POST');
      //req.setEndpoint(reqEndPoint);
      //req.setBodyAsBlob(bodyBlob);
      //req.setTimeout(120000);
 
      //Http http = new Http();
      //HTTPResponse res = http.send(req);
      return bodyBlob;
}   
    
}