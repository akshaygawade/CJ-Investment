@istest
public with sharing class BondBuyTest {
    
    @TestSetup
    private static void dataCreation(){
        
        
        List<Client__c> clients= new List<Client__c>();
        for (Integer a = 0; a <100; a++) {
            clients.add(new Client__c(Name = 'Test Client ' + a));
        }
        insert clients;
        
        
        
        List<Investor__c> invsts= new List<Investor__c>();
        for (Integer a = 0; a <100; a++) {
            invsts.add(new Investor__c(Name = 'Test Investor ' + a, Bonds_Pitched__c=0, Bonds_Purchased__c=0,Default_Bond_Units__c=50, Type__c='Universities'));
        }
        insert invsts;
        
        
        List<Bond_Offering__c> boofs = new List<Bond_Offering__c>();
        for (Integer a = 0; a< 100; a++) {
            boofs.add(new Bond_Offering__c( Name= 'Test ' + a , Client__c= clients[a].Id, Interest_Rate__c=5, Units_Pending__c = 0,Units_Sold__c = 0));
        }
        
        insert boofs;
        
        /*
        
        List<Bond_Buy__c> bbuy = new List<Bond_Buy__c>();
        for (Integer a = 0; a< 100; a++) {
            bbuy.add(new Bond_Buy__c( Bond_Offering__c = boofs[a].Id , Investor__c= invsts[a].Id, 
                                     Status__c = 'Pending',Units__c = 50));
        }
        
        insert bbuy;
        */
        
    }
    
    @istest
    private static void testBondBuyTriggerViaDML()
    {
        
       Investor__c invstId = [Select Id from Investor__c limit 1 ];
       Bond_Offering__c bondOfferingId =[Select Id from Bond_Offering__c limit 1 ];
       
       Bond_Buy__c testBondBuy = new Bond_Buy__c( Bond_Offering__c = bondOfferingId.Id , Investor__c= invstId.Id, 
                                     Status__c = 'Pending',Units__c = 50);
       Insert testBondbuy;
       
       //retrive the updated data
        Bond_Offering__c BondOffer = [SELECT Id,Units_Pending__c,Units_Remaining__c,Units_Sold__c FROM Bond_Offering__c WHERE Id=:bondOfferingId.Id];
        Investor__c Investor = [SELECT Id, Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c WHERE Id=:invstId.Id];
        System.assertEquals(50, BondOffer.Units_Pending__c);
        System.assertEquals(1000, BondOffer.Units_Remaining__c);
        System.assertEquals(0, BondOffer.Units_Sold__c);

        System.assertEquals(1,Investor.Bonds_Pitched__c);
        System.assertEquals(0,Investor.Bonds_Purchased__c);


    } 
    
    @istest
    private static void testBondBuyTriggerUpdateViaDML()
    {
        
       Investor__c invstId = [Select Id from Investor__c limit 1 ];
       Bond_Offering__c bondOfferingId =[Select Id from Bond_Offering__c limit 1 ];
       
       Bond_Buy__c testBondBuy = new Bond_Buy__c( Bond_Offering__c = bondOfferingId.Id , Investor__c= invstId.Id, 
                                     Status__c = 'Pending',Units__c = 50);
       Insert testBondbuy;
       

        testBondBuy.Units__c = 50;
        testBondBuy.Status__c = 'Purchased';
        
        UPDATE testBondBuy;

       //retrive the updated data
        Bond_Offering__c BondOffer = [SELECT Id,Units_Pending__c,Units_Remaining__c,Units_Sold__c FROM Bond_Offering__c WHERE Id=:bondOfferingId.Id];
        Investor__c Investor = [SELECT Id, Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c WHERE Id=:invstId.Id];
        System.assertEquals(0, BondOffer.Units_Pending__c);
        System.assertEquals(950, BondOffer.Units_Remaining__c);
        System.assertEquals(50, BondOffer.Units_Sold__c);

        System.assertEquals(1,Investor.Bonds_Pitched__c);
        System.assertEquals(1,Investor.Bonds_Purchased__c);

        
    } 
    
    @istest
    private static void testBondBuyTriggerDeleteUndeleteViaDML()
    {
       Investor__c invstId = [Select Id from Investor__c limit 1 ];
       Bond_Offering__c bondOfferingId =[Select Id from Bond_Offering__c limit 1 ];
       
       Bond_Buy__c testBondBuy = new Bond_Buy__c( Bond_Offering__c = bondOfferingId.Id , Investor__c= invstId.Id, 
                                     Status__c = 'Pending',Units__c = 50);
       Insert testBondbuy;
       Delete testBondbuy;
       
     //retrive the updated data
        Bond_Offering__c BondOffer = [SELECT Id,Units_Pending__c,Units_Remaining__c,Units_Sold__c FROM Bond_Offering__c WHERE Id=:bondOfferingId.Id];
        Investor__c Investor = [SELECT Id, Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c WHERE Id=:invstId.Id];
        System.assertEquals(0, BondOffer.Units_Pending__c);
        System.assertEquals(1000, BondOffer.Units_Remaining__c);
        System.assertEquals(0, BondOffer.Units_Sold__c);

        System.assertEquals(0,Investor.Bonds_Pitched__c);
        System.assertEquals(0,Investor.Bonds_Purchased__c);

      Undelete testBondbuy;
      
     //retrive the updated data
        Bond_Offering__c BondOffer2 = [SELECT Id,Units_Pending__c,Units_Remaining__c,Units_Sold__c FROM Bond_Offering__c WHERE Id=:bondOfferingId.Id];
        Investor__c Investor2= [SELECT Id, Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c WHERE Id=:invstId.Id];
        System.assertEquals(50, BondOffer2.Units_Pending__c);
        System.assertEquals(1000, BondOffer2.Units_Remaining__c);
        System.assertEquals(0, BondOffer2.Units_Sold__c);

        System.assertEquals(1,Investor2.Bonds_Pitched__c);
        System.assertEquals(0,Investor2.Bonds_Purchased__c);
        
    } 
    @istest
    private static  void testBondBuyAfterInsert()
    {
       Investor__c invstId = [Select Id from Investor__c limit 1 ];
       Bond_Offering__c bondOfferingId =[Select Id from Bond_Offering__c limit 1 ];
       
       Bond_Buy__c testBondBuy = new Bond_Buy__c( Bond_Offering__c = bondOfferingId.Id , Investor__c= invstId.Id, 
                                     Status__c = 'Pending',Units__c = 50);
   
       // BondBuyTriggerHandler.OnAfterInsert(new List<Bond_Buy__c> { testBondBuy});
    
    } 
    
    
    
    @istest
    private static  void TestCJAccountExecutives(){

        Profile p = [SELECT Id FROM Profile WHERE Name='CJ Account Executives'];
        
        User u1 = new User(Alias = 'standt1',Country='India',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1@camfed.org');
        insert u1;
        
        // now insert your test data

       System.runAs(u1){
            // you test for your controller
           // Test.startTest();
            //Bond Buy
            System.assert(schema.sObjectType.Bond_Buy__c.isAccessible());
            System.assert(schema.sObjectType.Bond_Buy__c.isCreateable());            
            System.assert(schema.sObjectType.Bond_Buy__c.isUpdateable());
            System.assert(schema.sObjectType.Bond_Buy__c.isDeletable());
            //Bond Offering
            System.assert(schema.sObjectType.Bond_Offering__c.isAccessible());
            System.assert(schema.sObjectType.Bond_Offering__c.isCreateable());            
            System.assert(schema.sObjectType.Bond_Offering__c.isUpdateable());
            System.assertNotEquals(True,schema.sObjectType.Bond_Offering__c.isDeletable(),'CJAccountExecutives User Profile Does Not Have Delete Permission on Bond Offering');
            //Client
            System.assert(schema.sObjectType.Client__c.isAccessible());
            System.assert(schema.sObjectType.Client__c.isCreateable());            
            System.assert(schema.sObjectType.Client__c.isUpdateable());
            System.assertNotEquals(True,schema.sObjectType.Client__c.isDeletable(),'CJAccountExecutives User Profile Does Not Have Delete Permission on Client');
            //Investor
            System.assert(schema.sObjectType.Investor__c.isAccessible());
            System.assertNotEquals(True,schema.sObjectType.Investor__c.isCreateable(),'CJAccountExecutives User Profile Does Not Have Create Permission on Investor');            
            System.assertNotEquals(True,schema.sObjectType.Investor__c.isUpdateable(),'CJAccountExecutives User Profile Does Not Have Update Permission on Investor');
            System.assertNotEquals(True,schema.sObjectType.Investor__c.isDeletable(),'CJAccountExecutives User Profile Does Not Have Delete Permission on Investor');
            
           // Test.stopTest();

        }
    }

   
    @istest
    private static  void testCJSalesReps(){

        Profile p = [SELECT Id FROM Profile WHERE Name='CJ Sales Reps'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo2@camfed.org');
        insert u1;
        
        // now insert your test data

       System.runAs(u1){
            // you test for your controller
           // Test.startTest();
           System.debug('creeeeeeeeeeeeeeeeeeee'+schema.sObjectType.Bond_Buy__c.isCreateable()); 
             //Bond Buy
            System.assert(schema.sObjectType.Bond_Buy__c.isAccessible());
            System.assertNotEquals(True,schema.sObjectType.Bond_Buy__c.isCreateable(),'CJSalesReps User Profile Does Not Have Create Permission on bond buy');
            System.assert(schema.sObjectType.Bond_Buy__c.isUpdateable());
            System.assertNotEquals(True,schema.sObjectType.Bond_Buy__c.isDeletable(),'CJSalesReps User Profile Does Not Have Delete Permission on bond buy');

            //Bond Offering
            System.assert(schema.sObjectType.Bond_Offering__c.isAccessible());
            System.assertNotEquals(True,schema.sObjectType.Bond_Offering__c.isCreateable(),'CJSalesReps User Profile Does Not Have Create Permission on Bond Offering');            
            System.assertNotEquals(True,schema.sObjectType.Bond_Offering__c.isUpdateable(),'CJSalesReps User Profile Does Not Have Edit Permission on Bond Offering');
            System.assertNotEquals(True,schema.sObjectType.Bond_Offering__c.isDeletable(),'CJSalesReps User Profile Does Not Have Delete Permission on Bond Offering');
            //Client
            System.assert(schema.sObjectType.Client__c.isAccessible());
            System.assertNotEquals(True,schema.sObjectType.Client__c.isCreateable(),'CJSalesReps User Profile Does Not Have Delete Permission on Client');            
            System.assertNotEquals(True,schema.sObjectType.Client__c.isUpdateable(),'CJSalesReps User Profile Does Not Have Delete Permission on Client');
            System.assertNotEquals(True,schema.sObjectType.Client__c.isDeletable(),'CJSalesReps User Profile Does Not Have Delete Permission on Client');
            //Investor
            System.assert(schema.sObjectType.Investor__c.isAccessible());
            System.assertNotEquals(True,schema.sObjectType.Investor__c.isCreateable(),'CJSalesReps User Profile Does Not Have Create Permission on Investor');            
            System.assertNotEquals(True,schema.sObjectType.Investor__c.isUpdateable(),'CJSalesReps User Profile Does Not Have Update Permission on Investor');
            System.assertNotEquals(True,schema.sObjectType.Investor__c.isDeletable(),'CJSalesReps User Profile Does Not Have Delete Permission on Investor');
            
           // Test.startTest();
        }
    }
}