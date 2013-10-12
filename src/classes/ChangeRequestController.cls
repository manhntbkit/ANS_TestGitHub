/**
* This controller is used as the extension in drawing CR Steps Diagram, creating a list of cr participants,
* and a list of cr components
*
* Author: Thanh Mai = tmai8@csc.com
* Date: 01/15/2013
* 
* Edited on 01/23/2013
* @by Han Nguyen 
* 
* Edited: Manh Nguyen = manhnt.bkit@gmail.com
* Notes: add migrate function.
*
*/
public class ChangeRequestController {

    private Change_Request__c changeRequest;
    private List<CR_Step__c> crStepList;
       
    private integer numOfClientStep = 0;
    private integer numOfPCStep = 0;
    private integer numOfPEStep = 0;
    private integer numOfSPMStep = 0;
    private integer numOfSCStep = 0;
    private integer numOfSEStep = 0;
    
    //These variables are used for creating a list of cr participants
    private Project__c project;
    private List<ClassCheckboxWrapper> wrapperList;
    private List<CR_Participant__c> newCrParticipantList; 
    private List<CR_Component__c> newCRComponentList;
    private Boolean nextStep = false;

    public Change_Request__c getChangeRequest() {
        return this.changeRequest;
    }
          
    public ChangeRequestController (ApexPages.StandardController controller) {
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
        this.nextStep = false;   
    }

    public List<CR_Step__c> getCRStepList() {
        return this.crStepList;
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
   private List<ClassCheckboxWrapper> buildWrapperList(List<sObject> projParticipantList){
       List<ClassCheckboxWrapper> pPWList = new List<ClassCheckboxWrapper>();
       for(sObject pp : projParticipantList){
           pPWList.add(new ClassCheckboxWrapper(pp));
       }  
       return pPWList;  
   }
   
   /** 
      * Get a list of Project Participant Wrappers
      */
   public List<ClassCheckboxWrapper> getProjectParticipantWrapperList() {
        //build a list of project participant wrappers
        this.wrapperList= buildWrapperList(this.project.Project_Participants__r);        
        return this.wrapperList;
    }
    
    public List<ClassCheckboxWrapper> getProjectComponentWrapperList() {
        // get participant groups
        this.project = [select id,(select id,Name,Chatter_Link__c  from Participant_Groups__r) 
        from Project__c 
        where id=:this.changeRequest.Project__c];  
           
        List<Participant_Group__c> projectParticipants =  this.project.Participant_Groups__r;
        List<Project_Component__c> projectComponents = new List<Project_Component__c>();
        
        //get project_components
        for(Participant_Group__c pp:projectParticipants){
           List<Project_Component__c> subprojectcomponents = [select id, Component_name__c, Chatter_Link__c from Project_Component__c
            where Chatter_Group__c=:pp.id];  
           projectComponents.addAll(subprojectcomponents);       
        }
        
        this.wrapperList = buildWrapperList(projectComponents);
        return this.wrapperList;
    
    }
    
   /**
   * Get new CR Participants list
   */ 
   public List<CR_Participant__c> getNewCrParticipantList() {
        return this.newCrParticipantList;
   }
   
   /**
   * Get new CR Component list
   */ 
   public List<CR_Component__c> getNewCrComponentList() {
        return this.newCrComponentList;
   }
    
   public Boolean getNextStep() {
       return this.nextStep;
   } 
    
    /** 
    * Build new CR Participants
    */
    public void buildNewCRParticipants() {
        List<CR_Participant__c> crParticipantList = new List<CR_Participant__c>();
        for(ClassCheckboxWrapper ppw : wrapperList) {
            if(ppw.selected == true){              
                CR_Participant__c newCRParticipant = new CR_Participant__c();
                newCRParticipant.Account__c =  ((Project_Participant__c)ppw.xobject).Account_Id__c;
                newCRParticipant.Chage_Request__c = this.changeRequest.Id;
                crParticipantList.add(newCRParticipant);    
            }
        }
       this.newCrParticipantList = crParticipantList;
    
       this.nextStep = true;
    }
    
     /** 
    * Build new CR Components
    */
    public void buildNewCRComponents() {
        List<CR_Component__c> crComponentList= new List<CR_Component__c>();
        for(ClassCheckboxWrapper ppw : wrapperList) {
            if(ppw.selected == true){              
                CR_Component__c newCRComponent = new CR_Component__c();
                newCRComponent.Change_Request__c = this.changeRequest.Id;
                newCRComponent.Name = ((Project_Component__c)(ppw.xobject)).Component_Name__c;                
                newCRComponent.Project_Component__c =  ((Project_Component__c)ppw.xobject).id; 
                //newCRComponent.Chatter_Group_Name__c = ((Project_Component__c)ppw.xobject).Chatter_Group__c; 
                //newCRComponent.Chatter_Group_ID__c = ((Project_Component__c)ppw.xobject).Chatter_Group_ID__c; 
                //newCRComponent.Chatter_Link__c = ((Project_Component__c)ppw.xobject).Chatter_Link__c; 
                               
                crComponentList.add(newCRComponent);    
            }
        }
       this.newCrComponentList = crComponentList;
    
       this.nextStep = true;
    }
    
    /**
    * Save new CR Participants into DB & commit
    */
    public PageReference save() {
        try {
            if(this.newCrParticipantList != null){
                insert this.newCrParticipantList;
            } else{
                insert this.newCRComponentList;
            }
           
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        // After Save, navigate to the default view page:
        return (new ApexPages.StandardController(this.changeRequest)).view();
    }
      
    private class ProjectParticipantWrapper extends ClassCheckboxWrapper{
        public ProjectParticipantWrapper(sObject xObject){
            super(xObject);
        }
        
        public override Project_Participant__c getCRParticipantObject() {
           return (Project_Participant__c) xobject;
        }    
    }
        
        
    //-------------------------- CR Step Templates ---------------------------------
    
    Public List<CR_Step_Template__c> getCRStepTemplates()
    {
        List<CR_Step_Template__c> allcons = [select id, name from CR_Step_Template__c limit 5];
        return allcons;
    }    
    
    /**
     * clone CR Steps in this template for current Change Request
     */
    public PageReference importTemplate()
    {
        String selTemplateId = System.currentPagereference().getParameters().get('tempId');
        System.debug('selected id : ' + selTemplateId);
        
        // 1. get all Steps in this Template (ListCRS).
        List<CR_Step_for_Template__c> listCRSTepTemp =  getCTStepsFromTemplate(selTemplateId);        
                
        // 2. insert ListCRS for this change request.
        //     2.1 mapping from CR_STep_For_Template__c --> CR_Step__c        
        List<CR_Step__c> CRSteps = convertToCRSteps(listCRSTepTemp);
        //     2.2 insert CRSteps into current Change Request
        try{
            insert CRSteps;        
        } catch(System.DMLException e){
            ApexPages.addMessages(e);
            return null;
        }
        // 3. merger relationship between steps
        mergerRelationshipToCRStep(listCRSTepTemp, CRSteps);                      
        
        // 4. back to current Change Request
        return (new ApexPages.StandardController(this.changeRequest)).view();           
        
    }
    
    private void mergerRelationshipToCRStep(List<CR_Step_for_Template__c> listCRSTepTemp, List<CR_Step__c> CRSteps){               
       for(CR_Step__c step : CRSteps){
           for(CR_Step_for_Template__c temp: listCRSTepTemp){              
               if(temp.Step_Number__c == step.Step_Number__c){
                   Boolean isUpdated = false;
                   // merger next step
                   if((temp.Next_CR_Step__c != null) && (step.Next_CR_Step__c == null)){
                      CR_Step_for_Template__c nextStepTemp = findCRStepTemp(temp.Next_CR_Step__c,listCRSTepTemp);
                      CR_Step__c nextStep = findCRStep(nextStepTemp.Step_Number__c, CRSteps);                                            
                      step.Next_CR_Step__c = nextStep.id;  
                      isUpdated = true;                                
                   }
                   // merger dependent step
                   if((temp.Dependent_CR_Step__c != null) && (step.Dependent_CR_Step__c == null)){
                      CR_Step_for_Template__c depStepTemp = findCRStepTemp(temp.Dependent_CR_Step__c,listCRSTepTemp);
                      CR_Step__c depStep = findCRStep(depStepTemp.Step_Number__c, CRSteps);                                            
                      step.Dependent_CR_Step__c = depStep.id;   
                      isUpdated = true;                                               
                   }
                   // merger alternative step               
                   if((temp.Alternate_CR_Step__c != null) && (step.Alternate_CR_Step__c == null)){
                      CR_Step_for_Template__c alStepTemp = findCRStepTemp(temp.Alternate_CR_Step__c,listCRSTepTemp);
                      CR_Step__c alStep = findCRStep(alStepTemp.Step_Number__c, CRSteps);                                            
                      step.Alternate_CR_Step__c = alStep.id;    
                      isUpdated = true;                                                
                   }
                   if(isUpdated == true){                       
                       upsert step;
                   }
               }
           }              
       }
    }    
    private CR_Step_for_Template__c findCRStepTemp(String CRStepTemID, List<CR_Step_for_Template__c> listCRSTepTemp){
        for(CR_Step_for_Template__c temp : listCRSTepTemp){
          if(temp.id == CRStepTemID){
              return temp;
          }
        }
        return null;    
    }
    private CR_Step__c findCRStep(Decimal tempStepNumber,List<CR_Step__c> CRSteps){
      for(CR_Step__c step: CRSteps){
          if(step.Step_Number__c == tempStepNumber){
              return step;          
          }
      }     
      return null;    
    } 
    
    
    private List<CR_Step__c> convertToCRSteps(List<CR_Step_for_Template__c> listCRSTepTemp){
        List<CR_Step__c> CRSteps = new List<CR_Step__c>();
        if(listCRSTepTemp == null || listCRSTepTemp.size() == 0){
                return  CRSteps;                
        }
        
        for(CR_Step_for_Template__c temp: listCRSTepTemp){
                CR_Step__c step = new CR_Step__c();
                step.Change_Request__c = this.changeRequest.id;
                step.Comments__c = temp.Comments__c;
                step.Criticality__c = temp.Criticality__c;
                step.Feed_Text__c = temp.Feed_Text__c;
                step.Process_Owner__c = temp.Process_Owner__c;
                step.Process_Step_Description__c = temp.Process_Step_Description__c;
                step.Process_Step_Name__c = temp.Process_Step_Name__c;
                step.Status__c = temp.Status__c;
                step.Step_Number__c = temp.Step_Number__c;
                step.Step_Type__c = temp.Step_Type__c;  
                
                CRSteps.add(step);                              
                                
        }
        
        return CRSteps;
        
    }
    
    private List<CR_Step_for_Template__c> getCTStepsFromTemplate(String templateId){
        CR_Step_Template__c temp = [select id , (select Comments__c, Criticality__c,
                Feed_Text__c, Process_Owner__c, Process_Step_Description__c, 
                Process_Step_Name__c, Status__c, Step_Number__c, Step_Type__c,
                Next_CR_Step__c, Dependent_CR_Step__c, Alternate_CR_Step__c
            FROM CR_Step_for_Templates__r) 
        FROM CR_Step_Template__c where id=:templateId];
                 
        return temp.CR_Step_for_Templates__r;
        
    }
    
    
    
    public PageReference viewTemplate() {       
        String selTemplateId = System.currentPagereference().getParameters().get('tempId');
        
        PageReference ReturnPage = new PageReference('/' + selTemplateId);        
            ReturnPage.setRedirect(true);
            return ReturnPage;
    }
     
     
           
}