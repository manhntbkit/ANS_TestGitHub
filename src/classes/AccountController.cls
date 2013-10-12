public with sharing class AccountController {
    /** 
    For testing pagination only
    **/
    public List<Account> accounts{
        get          
        {
            if(standardCon != null)
                return (List<Account>)standardCon.getRecords();
            else
                return null ;
        }
        set;}
    public Account acct {get; set;}
    
    
    
    public List<CR_Step__c> crStepList{get;set;}
    
    
    // init standard controller set
    public ApexPages.StandardSetController standardCon{get; set;}

    public AccountController(){
        
        //string sortFullExp = sortExpression  + ' ' + sortDirection;
      
        //query the database based on the sort expression
        //accounts = Database.query('SELECT id, name, rating, annualRevenue, industry FROM Account order by '  + sortFullExp + ' LIMIT 1000');
                      
        standardCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id, name, rating, annualRevenue, industry FROM Account LIMIT 1000]));
        
        //standardCon  = new ApexPages.StandardSetController(accounts);
        standardCon.setPageSize(5);
        
        accounts = new List<Account>() ;
        acct = new Account() ;    
        CR_Step__c c = new CR_Step__c();       
       
        crStepList = [Select  c.Process_Owner__c, c.Step_Type__c, c.Status__c, c.Process_Step_Name__c, c.Next_CR_Step__c, c.Name, c.Id, c.Feed_Text__c, c.Comments__c, c.Change_Request__c, c.Alternate_CR_Step__c From CR_Step__c c LIMIT 1000] ;
    }
    
    // Has next
    public Boolean hasNext
    {
        get
        {
            return standardCon.getHasNext();
        }
        set;
    }
    // Has previous
    public Boolean hasPrevious
    {
        get
        {
            return standardCon.getHasPrevious();
        }
        set;
    }
    
    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return standardCon.getPageNumber();
        }
        set;
    }
    // Move previous page of records
    public void previous()
    {
        standardCon.previous();
    }
 
    //Returns the next page of records
    public void next()
    {
        standardCon.next();
    }
    
    /*** Sortable ***/
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    
    public String sortExpression
    {
         get{ return sortExp; }
         set{
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
                 sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
                 sortDirection = 'ASC';
                 sortExp = value;
         }
   }

   public String getSortDirection()
   {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
             return sortDirection;
   }

   public void setSortDirection(String value)
   {  
       sortDirection = value;
   }
   
   public PageReference ViewData() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
      
       //query the database based on the sort expression
       accounts = Database.query('SELECT id, name, rating, annualRevenue, industry FROM Account order by '  + sortFullExp + ' LIMIT 1000');
       return null;
   }
    
}