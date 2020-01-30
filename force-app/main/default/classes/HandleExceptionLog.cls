/**
 * Exception handling utility class.  
 *
 * @author Akshay Gawade
 */


public without sharing class HandleExceptionLog {
	
	/**Exception log list*/	
private static list<ExceptionLog__c> lstException = new list<ExceptionLog__c>();

	/**Add exception in log list 
	* @param className - class name which cause exception
	* 	     methodName - method name which cause exception
	*		 ex - exception object 	
	*/
    
	public static void addLog(String className, String methodName, Exception ex){
	  
        ExceptionLog__c log = new ExceptionLog__c(
	        ClassName__c = className,
	        MethodName__c = methodName,
	        ErrorLine__c = ex.getLineNumber(),
	        ErrorMessage__c = ex.getMessage(),
	        ErrorDetails__c = ex.getStackTraceString()
	    );
        
	    lstException.add(log); 
	}

    //for customException
	public static void addCustomLog(String className, String methodName,String message){
	    ExceptionLog__c log = new ExceptionLog__c(
	        ClassName__c = className,
	        MethodName__c = methodName,
	        ErrorMessage__c = message
	    );
        
	    lstException.add(log); 
	}

	//Clear log list
	public static void clear(){
		lstException.clear();
	}

	//Save exception log in database
	public static void saveLog(){
		//insert exception records
	    if(!lstException.isEmpty())
	    {
	        upsert lstException;  //check previous record and update or insert new
	    }
  	}

}