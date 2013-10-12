public class ProjectParticipantsController {

    public List<Project_Participant__c> projectParticipants;
    public List<ProjectParticipantWrapper> projectParticipantsWrappers = new List<ProjectParticipantWrapper>();
    public List<Project_Participant__c> seletedParticipants = new List<Project_Participant__c>();
    public Project__c project;
    public Change_Request__c currentCR;   
    
    public ProjectParticipantsController(ApexPages.StandardController controller){
         currentCR = (Change_Request__c)controller.getRecord();
         List<Change_Request__c>   crs = [select cr.project__c from Change_Request__c cr where cr.id=:currentCR.id];
         if(crs.size() > 0){
            Change_Request__c cr = crs.get(0);
            projectParticipants = [select id, name, Account_ID__c,Area_Of_Expertise__c, Project_ID__c, Project_Tier__c
                                     from Project_Participant__c where Project_ID__c =:cr.Project__c];
         }
         
    } 
    
    public List<ProjectParticipantWrapper> getProjectParticipants(){
        for(Project_Participant__c p: projectParticipants ){
            projectParticipantsWrappers.add(new ProjectParticipantWrapper(p) );
        }    
        return projectParticipantsWrappers;    
    }   
    
    public Project__c getProject(){
        return project;
    }
    
    public void addParticipants(){
        filterSelectedParticipants();
        if(seletedParticipants.size() > 0){
            addCRParticipants();        
        }             
    
    }
    
    private void addCRParticipants(){
        for(Project_Participant__c pp: seletedParticipants){
            CR_Participant__c cr_pp = new CR_Participant__c();
            cr_pp.Account__c = pp.Account_ID__c;
            cr_pp.Chage_Request__c = this.currentCR.id ;
            insert cr_pp;    
        }           
    }
    
    private void filterSelectedParticipants(){
        seletedParticipants.clear();
        for(ProjectParticipantWrapper pp: projectParticipantsWrappers){
            if(pp.selected == true){
                seletedParticipants.add(pp.projectParticipant);
            }        
        }            
    
    }
        
    public class ProjectParticipantWrapper {
        public Project_Participant__c projectParticipant{get;set;}
        public Boolean selected{get;set;}
        
        public ProjectParticipantWrapper(Project_Participant__c p)
        {
            projectParticipant = p;
            selected = false;            
        }  
    
    }
     
}