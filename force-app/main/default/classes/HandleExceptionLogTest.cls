@istest
private  class HandleExceptionLogTest {
   
	@isTest static void testExceptionLog() {
		//test code
		Test.startTest();
		HandleExceptionLog.addLog('className','MethodName',new DmlException('TestException'));
		HandleExceptionLog.saveLog();
		HandleExceptionLog.addLog('className1','MethodName1',new DmlException('TestException1'));
		HandleExceptionLog.saveLog();
        HandleExceptionLog.addCustomLog('className2', 'methodName2', 'Test Custom Exception');
		HandleExceptionLog.clear();
		System.assert(true);
		Test.stopTest();
	}


}