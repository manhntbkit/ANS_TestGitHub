/**
 * wrapping any classes with checkbox
*/

public virtual class ClassCheckboxWrapper
{
        public sObject xobject {get;set;}      
        public Boolean selected {get;set;}
        public ClassCheckboxWrapper(sObject input){
            xobject = input;
            selected = false;        
        }
        
        public virtual Project_Participant__c getCRParticipantObject() {
           return (Project_Participant__c) xobject;
        }
        
        public virtual Project_Component__c getCRComponentObject() {         
           return (Project_Component__c) xobject;
        }          
}