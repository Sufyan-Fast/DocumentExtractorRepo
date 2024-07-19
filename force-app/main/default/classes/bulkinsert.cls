public class bulkinsert {
    
    public static void main()
    {
        list<Hospital_Affiliation__c> HFlist = new list<Hospital_Affiliation__c>();
        for(integer i=1; i<=50 ; i++)
        {
            Hospital_Affiliation__c HF = new Hospital_Affiliation__c();
            HF.Credentialing_Entity__c= 'a2d8J000000XXvhQAG';
            HF.Provider__c='0038J00000EjOLjQAN';
            HFlist.add(HF);
        }
        insert HFlist;
        
    } 



}