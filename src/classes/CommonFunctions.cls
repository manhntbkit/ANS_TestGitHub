/****************************
Created By : Siva Vittala (svittala@csc.com)
Created Date : 1/14/2013
- this class holds all common functions that will be used in this org
- they are declared as public static void functions so can be accessed easily
*****************************/


public class CommonFunctions {
    public static set <ID> getChatterGroupsforCRStep ( ID changeRequestID ) {
    	 set <ID> setChatterGroupnames = new set<ID> ();
         integer i = 0;
         For (CR_Component__c crcomponents:[select chatter_group_ID__C from CR_Component__c where 
                                                      Change_Request__C  = :changeRequestID]) {
             setChatterGroupnames.add(crcomponents.chatter_group_id__c);
             system.debug('Came here WITH '+ crcomponents.chatter_group_id__c);
                                                       
         }
          system.debug ('came out');
          if (setChatterGroupnames.isEmpty()) 
              	return null;
          return setChatterGroupnames ;
    }
public static string getChatterStringforCR ( ID changeRequestID ) {
          string stringName = '';
          For (List <Change_Request__c> licr:[select name from Change_Request__c where 
                                                      ID  = :changeRequestID]) {
                                                          stringName = licr[0].name;   
                                                      }
         return stringName ;
    }
    
}