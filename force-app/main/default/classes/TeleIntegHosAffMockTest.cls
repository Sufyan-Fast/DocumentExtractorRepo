public class TeleIntegHosAffMockTest implements HttpCalloutMock {
    
    public static Httpresponse Respond( HttpRequest req){
        
        String ResponseBody =  '{"telercare_user_id":"003DU00000goiDNYAY","SecretKey":"123456789","salesforce_user_id":"7430000054","credentialing_entity":"TestCred","credentialing_entity_id":"003DU00000goiDNYAY","end_date":"2024-09-04T11:38:29.641Z","start_date":"2023-09-04T11:38:29.641Z"}';   
        
        HttpResponse res = new HttpResponse();
    
        res.setHeader('Content-Type', 'Application/JSON');
        
        res.setBody( ResponseBody );
        
        res.setStatusCode(200);
        
        return res;
        
    }

}