public class ContactOwnerChangeHandlelrClass {
    
    public static final Id User_1 = Label.Physician_Liaisons_1;
    public static final Id User_2 = Label.Physician_Liaisons_2;
    public static final Id User_3 = Label.Physician_Liaisons_3;

    public static list<Contact> getRecords(Id owner_Id)
    {
        return [Select Id, FirstName,LastName, OwnerId From Contact Where OwnerId =:owner_Id];
    }
    public static Boolean checkSmall(Integer arg1, Integer arg2, Integer arg3)
    {
        return (arg1 <= arg2 && arg1 <= arg3)? true : false;
    }
    
    public static void updateOwnerField( map<Id,Contact> phyLiaList)
    {
        List<Integer> counter = new List<Integer>{0,0,0};
        List<Contact> ConLst = new List<Contact>();
                
                list<Contact> User_1_Records = getRecords(User_1);
                counter[0] = User_1_Records.size();
                list<Contact> User_2_Records = getRecords(User_2);
                counter[1] = User_2_Records.size();
                list<Contact> User_3_Records = getRecords(User_3);
                counter[2] = User_3_Records.size();
                
                for ( Contact Con :  phyLiaList.values() ){
                    
                    Contact newObj = new Contact();
                    if ( checkSmall(counter[0], counter[1], counter[2]) ) {
                        newObj.Id = Con.Id;
                        newObj.OwnerId = User_1; 
                        counter[0]++;
                    } else if ( checkSmall(counter[1], counter[0], counter[2]) ) {
                         newObj.Id = Con.Id;
                         newObj.OwnerId = User_2;
                        counter[1]++;
                    } else  {
                         newObj.Id = Con.Id;
                         newObj.OwnerId = User_3;
                        counter[2]++;
                    } 
                    
                    ConLst.add(newObj);
                            
                }
                if(!ConLst.isEmpty())
                {
                Update ConLst;
                }
            

    }

}