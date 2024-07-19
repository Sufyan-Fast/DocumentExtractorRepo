public class bulkdelete {
    
      public static void main() {
        List<Hospital_Privilege_Application__c> HPAlst = [SELECT Id, Credentialing_Entity__c, Provider__c FROM Hospital_Privilege_Application__c WHERE Credentialing_Entity__c = 'a2d8J000000XY5zQAG' AND Provider__c = '0038J00000E9ALhQAN' LIMIT 220];
        
        delete HPAlst;
    }

}