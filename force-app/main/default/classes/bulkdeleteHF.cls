public class bulkdeleteHF {
    
     public static void main() {
        List<Hospital_Affiliation__c> HFlst = [SELECT Id, Credentialing_Entity__c, Provider__c FROM Hospital_Affiliation__c WHERE Credentialing_Entity__c = 'a2d8J000000XXvhQAG' AND Provider__c = '0038J00000EjOLjQAN' LIMIT 50];
        
        delete HFlst;
    }

}