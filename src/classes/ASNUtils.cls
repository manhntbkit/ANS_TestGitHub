global with sharing class ASNUtils {
    
    /**
    *** Get Picklist Value from any Object
    *** @param: obj is Object in Salesforce
    *** @param: fieldPinklist the field with picklist type
    *** @return: List<Selection> type
    ***
    *** Author by Kien Nghe
    *** email: knghe@csc.com
    **/
    global static list<SelectOption> getPicklistValues(SObject obj, String fieldPicklist)   {
      
      list<SelectOption> options = new list<SelectOption>();
      
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();    
         
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fieldPicklist).getDescribe().getPickListValues();
      
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry entry : values)
      { 
         options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
      }
      
      return options;
   }
   
}