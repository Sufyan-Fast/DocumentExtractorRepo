public class InvockedBulkCallsHospitalAffliliation {

		
    @InvocableMethod(label='Create Call Tasks' description='Creates Call Tasks for HPA records')
    public static void CreateCallTasks(List<ContentCallInput> inputList) {
        
        if (inputList != null && !inputList.isEmpty()) {
            
            List<Hospital_Affiliation__c>  ListtoUpdateCalls = new List<Hospital_Affiliation__c>();
            List<Hospital_Affiliation__c> HPAList = inputList[0].HospitalAffiliation;

        if (HPAList != null) {
                List<Id> HPAIds = new List<Id>();
                List<Task> taskList = new List<Task>();
                
                for (Hospital_Affiliation__c HPALists : HPAList) {
                    
                    Task callTask = new Task();

                    callTask.Description = inputList[0].ContentScreen;
                    callTask.Subject = inputList[0].Subject;
                    callTask.Type = inputList[0].TaskType;
                    callTask.Status = 'Completed';
                    callTask.TaskSubtype = 'Call';
                    callTask.WhatId = HPALists.Id;
                    calltask.ActivityDate = system.today();
                   
                 
                     
                    taskList.add(callTask);
                    HPAIds.add(HPALists.Id);
                    ListtoUpdateCalls.add(HPALists);
                    
                } 
                
                insert taskList;
                update  ListtoUpdateCalls;
                
            }
        }
    }

    public class ContentCallInput {
      
		
        @InvocableVariable(label='Subject' description='Value From Screen Input')
        public String Subject;
        
        @InvocableVariable(label='Content Screen Value' description='Value from Screen Input')
        public String ContentScreen;
        
        
        @InvocableVariable(label='Task Type' description='Value From Screen Input')
        public String TaskType;
        
        @InvocableVariable(label='Task Status' description='Value from Screen Input')
        public String TaskStatus;

        @InvocableVariable(label='HPA Records' description='List of HPA records')
        public List<Hospital_Affiliation__c> HospitalAffiliation;
    }
    
}