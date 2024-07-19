public class Datatable {

    @auraEnabled(cacheable=true)
    public static list<account> ShowListOfHotels( ){
        return[select id , name, Phone from account ];
    }    
    
    @auraEnabled(cacheable=true)
    public static list<account> ShowFilterredList( String result ){

       string searchVar = '%' + result + '%' ;
       return [select id , name, Phone from account WHERE Name LIKE : searchVar];
   } 
}