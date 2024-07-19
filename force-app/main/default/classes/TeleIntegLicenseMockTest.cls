public class TeleIntegLicenseMockTest implements HttpCalloutMock{

    public static Httpresponse Respond( HttpRequest req){
        
        String ResponseBody =  '{ "telercare_user_id ":"e9e119e4-d96c-4108-a984-25f79c837e0e","salesforce_user_id":"003DU00000h3RM8YAM","license_number ":"4353400","license_type_id":"a1yDU0000049jGwYAI","license_type_name":"Doctor of Osteopathy","is_active":"True","license_state ":"GA", "expired_date":"2024-09-04T11:38:29.641Z", "issued_date":"2024-09-04T11:38:29.641Z","SecretKey":"123456789" }';   
                 
        HttpResponse res = new HttpResponse();
    
        res.setHeader('Content-Type', 'Application/JSON');
        
        res.setBody( ResponseBody );
        
        res.setStatusCode(200);
        
        return res;
        
    }
}