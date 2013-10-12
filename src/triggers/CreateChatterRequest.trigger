trigger CreateChatterRequest on CR_Step__c (after update) {
// use this trigger to send a chatter request for each of the step
    List <FeedItem> filist = new List<FeedItem>();
    // for each new record updated create a chatter feed
    // for every chatter group associated with the CR
    // get the list of chatter groups to a set and put it into a list
     string strChatterMessage = '';
    
    For ( CR_Step__c crstep : trigger.new ) {
         set <ID> setChatterGroup = commonFunctions.getChatterGroupsforCRStep( crstep.change_request__c);
         if(setChatterGroup != null ){
             strChatterMessage = commonFunctions.getChatterStringforCR (crstep.change_request__c);
                system.debug(' the set is ' + setChatterGroup.size());
                For (ID chattergroupid  : setChatterGroup){
                    FeedItem post = new FeedItem();
                    post.ParentId = chattergroupid;
                    // CR_Process_ID + ' Step for ' + Process_Owner__C + ' moved to '+ Status__C    
                    post.body = strChatterMessage + '- Step: ' + crstep.Process_Step_Name__c + ' under ' + crstep.process_owner__C + ' stream Changed Status to '+ crstep.status__c;
                    filist.add(post);
                    
                 }
             }
            insert filist;         
         }          
    }