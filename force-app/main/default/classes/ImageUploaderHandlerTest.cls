@isTest
private class ImageUploaderHandlerTest {

    @isTest
    static void testMethods() {
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test record';
        insert acc;


        Id recordId = acc.Id; // Replace with a valid Record Id
        String strFileName = 'testFileName';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test content'));

                    //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = acc.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;
            

        
        ContentVersion cv1 = ImageUploaderHandler.saveFile(recordId, strFileName, base64Data);
        


        System.assertEquals(strFileName + ' - ProfilePicture ' + recordId, cv1.Title);
        System.assertEquals('/' + strFileName, cv1.PathOnClient);
        System.assertEquals(recordId, cv1.FirstPublishLocationId);
        System.assertNotEquals(null, cv1.VersionData);

        
        String imageUrl = ImageUploaderHandler.setImageUrl(recordId);
    
 

        System.assertNotEquals(null, imageUrl);

        
        ImageUploaderHandler.deleteFiles(recordId);
        Test.stopTest();

        List<ContentDocument> deletedDocuments = [
            SELECT Id, Title, Description
            FROM ContentDocument
            WHERE Id =: recordId // Replace with the valid Content Document Id
        ];

        System.assertEquals(0, deletedDocuments.size());






    }

 
   
}