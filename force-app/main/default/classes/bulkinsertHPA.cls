public class bulkinsertHPA {

  public static void main(){
      
        list<Hospital_Privilege_Application__c> HPAlist = new list<Hospital_Privilege_Application__c>();
        for(integer i=1; i<=120 ; i++)
        {
            Hospital_Privilege_Application__c HPA = new Hospital_Privilege_Application__c();
            HPA.Credentialing_Entity__c= 'a2d8J000000XY5zQAG';
            HPA.Provider__c='0038J00000E9ALhQAN';
            HPAlist.add(HPA);
        }
        insert HPAlist;
        
    }

}