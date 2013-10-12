/**
* This controller is used as extension in CR Steps Diagram only.
*
* Author: Thanh Mai = tmai8@csc.com
* Date: 01/15/2013
*/
public class ChangeRequestStepListController {

    private Change_Request__c changeRequest;
    private List<CR_Step__c> crStepList;
    private Map<String, String> nextPointMap;
    private Map<String, String> alternatePointMap;
    
    public Change_Request__c getChangeRequest() {
        return this.changeRequest;
    }
    
    public Map<String, String> getNextPointMap() {
        return this.nextPointMap;
    }
    
    public Map<String, String> getAlternatePointMap() {
        return this.alternatePointMap;
    }
    
    public ChangeRequestStepListController(ApexPages.StandardController controller) {
        Change_Request__c workingChangeRequest = (Change_Request__c)controller.getRecord();
        this.changeRequest = [SELECT Id, Name, (SELECT Name, Step_Type__c, Process_Step_Name__c, 
                                                                Next_CR_Step__c, 
                                                                Alternate_CR_Step__c,
                                                                Dependent_CR_Step__c,
                                                                Status__c, Process_Owner__c
                                                FROM CR_Steps__r)
                              FROM Change_Request__c WHERE ID=:workingChangeRequest.Id];
        
        //Build the needed data for diagram.
        this.crStepList = this.changeRequest.CR_Steps__r;
        nextPointMap = this.buildNextPointMap(this.crStepList);
        alternatePointMap = this.buildAlternatePointMap(this.crStepList);
    }

    public List<CR_Step__c> getCRStepList() {
        return this.crStepList;
    }
    
    /** 
        * This is to build a map of next points in a change request.
        */
    private Map<String, String> buildNextPointMap(List<CR_Step__c> crStepList) {
        Map<String,String> returnMap = new Map<String,String>();
        for (CR_Step__c currentStep : crStepList) {
            List<CR_Step__c> stepList = [SELECT Id FROM CR_Step__c WHERE Name=:currentStep.Next_CR_Step__c];            
            if (stepList.size()>0) {
                returnMap.put(currentStep.Id, stepList.get(0).Id);
            }
        }
        return returnMap;
    }
    
    /** 
        * This is to build a map of alternate points in a change request.
        */
    private Map<String, String> buildAlternatePointMap(List<CR_Step__c> crStepList) {
        Map<String,String> returnMap = new Map<String,String>();
        for (CR_Step__c currentStep : crStepList) {
            List<CR_Step__c> stepList = [SELECT Id FROM CR_Step__c WHERE Name=:currentStep.Alternate_CR_Step__c];            
            if (stepList.size()>0) {
                returnMap.put(currentStep.Id, stepList.get(0).Id);
            }
        }
        return returnMap;
    }    
    
}