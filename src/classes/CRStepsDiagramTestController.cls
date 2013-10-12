public with sharing class CRStepsDiagramTestController {
   
   private List<String> processOwnerList = new List<String>();
   
   private List<CR_Step__c> listOwnerStep;
   
   private Map<String, List<CR_Step__c>> mapProcessOwner = new Map<String, List<CR_Step__c>>();
    
   public Change_Request__c changeRequest{
        get {
            if (changeRequest == null)
                changeRequest = new Change_Request__c();
            return changeRequest;
        }
        
        set;    
   }
   
   // Default contructor
   public CRStepsDiagramTestController(){
       String changeRequestId = changeRequest.Id;
       
       // Get all process owner type
       list<SelectOption> testOptions =  ASNUtils.getPicklistValues(new CR_Step__c(), 'Process_Owner__c');
       
       for(SelectOption optionId : testOptions){
           processOwnerList.add(optionId.getLabel());
       }
   }
    
   public List<String> getProcessOwnerList(){
       return this.processOwnerList;
   }
   
   public List<CR_Step__c> getListOwnerStep(String processOwnerName){
       List<CR_Step__c> stepList = [SELECT c.Process_Owner__c, c.Step_Type__c, c.Status__c, c.Process_Step_Name__c, c.Next_CR_Step__c, c.Name, c.Id, c.Feed_Text__c, c.Comments__c, c.Change_Request__c, c.Alternate_CR_Step__c FROM CR_Step__c c WHERE c.Process_Owner__c=:processOwnerName];
       
       return stepList;
   }
   
   public Map<String, List<CR_Step__c>> getMapProcessOwner(){
       for(String proOwnName: processOwnerList){
           mapProcessOwner.put(proOwnName, getListOwnerStep(proOwnName));
       }
       return mapProcessOwner;
   }
    
}