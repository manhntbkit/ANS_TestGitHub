public class CRParticipantExtension {

    public CRParticipantExtension(ApexPages.StandardController controller) {

    }


    private List<CR_Participant__c> newCrParticipantList; 
    
    public CRParticipantExtension(List<CR_Participant__c> crParticipantList) {
        this.newCrParticipantList = crParticipantList;
    }
    
    /**
   * Get new CR Participants list
   */ 
   public List<CR_Participant__c> getNewCrParticipantList() {
        return this.newCrParticipantList;
   }

}