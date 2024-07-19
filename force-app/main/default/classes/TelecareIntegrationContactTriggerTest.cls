public class TelecareIntegrationContactTriggerTest implements HttpCalloutMock{

    public static HttpResponse respond(HttpRequest req){
        
        String ResponseBody =  '{"sforce_id":"003DU00000goiDNYAY","SecretKey":"123456789","NPINumber":"7430000054","MobilePhone":"7430000054","LastName":"TestContact1","IsActive":true,"Gender":"TestGender","FirstName":"TestContact1","Email":"TestData1@gmail.com","ContractDate":"2023-10-04T12:35:40.523Z","AddressBlock":"Example"}';   
        
        HttpResponse res = new HttpResponse();
    
        res.setHeader('Content-Type', 'Application/JSON');
        
        res.setBody( ResponseBody );
        
        res.setStatusCode(200);
        
        return res;
        
       
    
    }
    
    
}