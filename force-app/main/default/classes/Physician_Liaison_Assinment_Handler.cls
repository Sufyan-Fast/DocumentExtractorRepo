public class Physician_Liaison_Assinment_Handler {
    
    public static final Id Physician_liaison_1 = Label.Physician_Liaisons_1;
    public static final Id Physician_liaison_2 = Label.Physician_Liaisons_2;
    public static final Id Physician_liaison_3 = Label.Physician_Liaisons_3;

    public static list<Physician_Liaison__c> getRecords(Id owner_Id)
    {
        return [Select id, Last_Name__c, OwnerId From Physician_Liaison__c Where OwnerId =:owner_Id];
    }
    public static Boolean checkSmall(Integer arg1, Integer arg2, Integer arg3)
    {
        return (arg1 <= arg2 && arg1 <= arg3)? true : false;
    }
    
    public static void afterInsert( map<Id,Physician_Liaison__c> phyLiaList)
    {
        List<Integer> counter = new List<Integer>{0,0,0};
        List<Physician_Liaison__c> PhyLst = new List<Physician_Liaison__c>();
                
                list<Physician_Liaison__c> Physician_liaison_1_Records = getRecords(Physician_liaison_1);
                counter[0] = Physician_liaison_1_Records.size();
                list<Physician_Liaison__c> Physician_liaison_2_Records = getRecords(Physician_liaison_2);
                counter[1] = Physician_liaison_2_Records.size();
                list<Physician_Liaison__c> Physician_liaison_3_Records = getRecords(Physician_liaison_3);
                counter[2] = Physician_liaison_3_Records.size();
                
                for ( Physician_Liaison__c PhyLi :  phyLiaList.values() ){
                    
                    Physician_Liaison__c newObj = new Physician_Liaison__c();
                    if ( checkSmall(counter[0], counter[1], counter[2]) ) {
                        newObj.Id = PhyLi.Id;
                        newObj.OwnerId = Physician_liaison_1; 
                        counter[0]++;
                    } else if ( checkSmall(counter[1], counter[0], counter[2]) ) {
                         newObj.Id = PhyLi.Id;
                         newObj.OwnerId = Physician_liaison_2;
                        counter[1]++;
                    } else  {
                         newObj.Id = PhyLi.Id;
                         newObj.OwnerId = Physician_liaison_3;
                        counter[2]++;
                    } 
                    
                    PhyLst.add(newObj);
                            
                }
                if(!PhyLst.isEmpty())
                {
                Update PhyLst;
                }
            

    }

}