/**
* This controller is used as extension in CR Steps Diagram only.
*
* Author: Thanh Mai = tmai8@csc.com
* Date: 01/15/2013
* 
* Edited by Han Nguyen
*/
public class ChangeRequestFlow2Controller {

    private Change_Request__c changeRequest;
    private List<CR_Step__c> crStepList;
    private Map<String, CR_Step__c> crStepMap;
    private String startingStepName;
    
    private Project__c project;
    private List<ProjectParticipantWrapper> projParticipantWrapperList;
    private List<CR_Participant__c> newCrParticipantList; 
    private Boolean nextStep = true;
    
    private integer numOfClientStep = 0;
    private integer numOfPCStep = 0;
    private integer numOfPEStep = 0;
    private integer numOfSPMStep = 0;
    private integer numOfSCStep = 0;
    private integer numOfSEStep = 0;

    public Change_Request__c getChangeRequest() {
        return this.changeRequest;
    }
    
    public String getStartingStepName() {
        startingStepName = 'CRP#00016'; //have starting step type?
        return this.startingStepName;
    } 
    
    public Map<String, CR_Step__c> getCRStepMap() {
        return this.crStepMap;
    }
    
    public ChangeRequestFlow2Controller (ApexPages.StandardController controller) {
        Change_Request__c workingChangeRequest = (Change_Request__c)controller.getRecord();
        this.changeRequest = [SELECT Id, Name, Project__c, (SELECT Name, Step_Type__c, Process_Step_Name__c, 
                                                                Next_CR_Step__c, 
                                                                Alternate_CR_Step__c,
                                                                Dependent_CR_Step__c,
                                                                Status__c, Process_Owner__c
                                                FROM CR_Steps__r)
                              FROM Change_Request__c WHERE ID=:workingChangeRequest.Id];
                              
        this.project = [SELECT Id, (SELECT Name, Account_ID__c, Area_Of_Expertise__c, Project_Tier__c
                                    FROM Project_Participants__r)
                                                
                        FROM Project__c WHERE ID=:changeRequest.Project__c];
        
        //Build the needed data for diagram.
        this.crStepList = this.changeRequest.CR_Steps__r;
        this.crStepList.sort();
      
        countOwerTypeSteps(this.crStepList);
        this.crStepMap = buildCRStepMap(this.crStepList);
        //alternatePointMap = this.buildAlternatePointMap(this.crStepList);
        
        //build a list of project participant wrappers
        this.projParticipantWrapperList= buildProjectParticipantWrapperList(this.project.Project_Participants__r);
        this.nextStep = true;
    }

    public List<CR_Step__c> getCRStepList() {
        return this.crStepList;
    }
   
    /** 
        * This is to build a map of next points in a change request.
        */
    private Map<String, CR_Step__c> buildCRStepMap(List<CR_Step__c> crStepList) {
        Map<String,CR_Step__c> returnMap = new Map<String,CR_Step__c>();
        for (CR_Step__c currentStep : crStepList) {           
                returnMap.put(currentStep.Name, currentStep);
        }
        return returnMap;
    }
    
       
    private void countOwerTypeSteps(List<CR_Step__c> crStepList) {
        for(CR_Step__c step: crStepList) {
            if (step.Process_Owner__c == 'Client')  
                numOfClientStep++;
            else if (step.Process_Owner__c == 'Prime Commercial')  
                numOfPCStep++;
            else if (step.Process_Owner__c == 'Prime Engineering')  
                numOfPEStep++;
            else if (step.Process_Owner__c == 'SPM')  
                numOfSPMStep++;
            else if (step.Process_Owner__c == 'Sub Commercial')  
                numOfSCStep++;
            else if (step.Process_Owner__c == 'Sub Engineering')  
                numOfSEStep++;   
                                
        }        
    }
     public integer getNumOfClientStep() {
         return numOfClientStep; 
      }
    public integer getNumOfPCStep() {
         return numOfPCStep; 
      }
    public integer getNumOfPEStep() {
         return numOfPEStep; 
      }
    public integer getNumOfSPMStep() {
         return numOfSPMStep; 
      }
    public integer getNumOfSCStep() {
         return numOfSCStep; 
      }
    public integer getNumOfSEStep() {
         return numOfSEStep; 
      }        
   
   /** 
      * Build a list of Project Participant Wrappers
      */
   private List<ProjectParticipantWrapper> buildProjectParticipantWrapperList(List<Project_Participant__c> projParticipantList){
       List<ProjectParticipantWrapper> pPWList = new List<ProjectParticipantWrapper>();
       for(Project_Participant__c pp : projParticipantList){
           pPWList.add(new ProjectParticipantWrapper(pp));
       }  
       return pPWList;  
   }
   
   /** 
      * Get a list of Project Participant Wrappers
      */
   public List<ProjectParticipantWrapper> getProjectParticipantWrapperList() {
        return this.projParticipantWrapperList;
    }
    
   /**
   * Get new CR Participants list
   */ 
   public List<CR_Participant__c> getNewCrParticipantList() {
        return this.newCrParticipantList;
   }
    
   public Boolean getNextStep() {
       return this.nextStep;
   } 
    
    /** 
    * Build new CR Participants
    */
    public void buildNewCRParticipants() {
        List<CR_Participant__c> crParticipantList = new List<CR_Participant__c>();
        for(ProjectParticipantWrapper ppw : projParticipantWrapperList) {
            if(ppw.selected == true){              
                CR_Participant__c newCRParticipant = new CR_Participant__c();
                newCRParticipant.Account__c =  ppw.projParticipant.Account_Id__c;
                newCRParticipant.Chage_Request__c = this.changeRequest.Id;
                crParticipantList.add(newCRParticipant);    
            }
        }
       this.newCrParticipantList = crParticipantList;
    
       this.nextStep = false;
    }
    
    /**
    * Save new CR Participants into DB & commit
    */
    public PageReference save() {
        try {
           insert this.newCrParticipantList;
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        // After Save, navigate to the default view page:
        return (new ApexPages.StandardController(this.changeRequest)).view();
    }
   /**
   * The class wraps the Project Participant
   */
   public class ProjectParticipantWrapper
    {
        public Project_Participant__c projParticipant {get; set;}
        public Boolean selected {get; set;}
        public ProjectParticipantWrapper(Project_Participant__c pp)
        {
           projParticipant = pp;
           selected = false;
        }
    }
}