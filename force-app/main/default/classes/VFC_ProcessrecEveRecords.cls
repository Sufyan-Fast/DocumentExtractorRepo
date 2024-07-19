public class VFC_ProcessrecEveRecords {
    
    public List<Recruitment_Event__c> selrecEveLst;
      public String recEveIds;

      // Constructor
      public VFC_ProcessrecEveRecords(ApexPages.StandardSetController cntlr){
           selrecEveLst = cntlr.getSelected(); //get selected records from Recruitment_Event__c list view
           recEveIds = '';  
           for(Recruitment_Event__c acc : selrecEveLst){
               recEveIds += acc.Id + ','; //build list of ids string concatenated with comma                         
            }
           recEveIds = recEveIds.removeEnd(',');
          System.debug('recEveIds' + recEveIds);
      } 
		/*
      public PageReference redirectToLC(){
            String returnUrl = '/lightning/cmp/c__listofRecruitEvents?c__listofRecEvents='+recEveIds;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
      }
*/

}