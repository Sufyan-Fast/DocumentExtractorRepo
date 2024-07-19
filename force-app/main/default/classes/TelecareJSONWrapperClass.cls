public class TelecareJSONWrapperClass {

    public class ContactWrapper{
    
        public string sforce_id { get; set; }
        public String Email { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Gender { get; set; }
        public String NPINumber { get; set; }
        public String MobilePhone { get; set; }
        public String AddressBlock { get; set; }
        public Boolean IsActive { get; set; }
        public DateTime ContractDate { get; set; }
        public string SecretKey { get; set; }
        
    }
    
    
    public class UpdateContactWrapper{
        
        public string Id { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string NPINumber { get; set; }
        public string MobilePhone { get; set; }
        public string AddressBlock { get; set; }
        public Boolean IsActive { get; set; }
        public string sforce_id { get; set; }
        public string SecretKey { get; set; }
        
    }
    
    public class HospitalAffiliationUpdateWrapper{
        
        public String telercare_user_id { get; set; }	
        public String salesforce_user_id { get; set; }	
        public String credentialing_entity { get; set; }	
        public String credentialing_entity_id { get; set; }	
        public String start_date { get; set; }	
        public String end_date { get; set; }
        public string SecretKey { get; set; }
        public string ApprovalDate { get; set; }
        public string is_active { get; set; }
        
    }    
    
    public class ProviderLicenseInformation{
        
        public string telecare_user_id { get; set; }
        public string salesforce_user_id { get; set; }
        public string license_number { get; set; }
        public string license_type_id { get; set; }
        public string license_type_name { get; set; }
        public string issued_date { get; set; }
        public string expired_date { get; set; }
        public string licensure_board_id { get; set; }
        public string licensure_board_name { get; set; }
        public string is_active { get; set; }
        public string license_state { get; set; }
        public string SecretKey { get; set; }
        
    }
    
    
    
    
    
    
    
    
    

}