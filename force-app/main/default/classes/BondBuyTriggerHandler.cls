public with sharing class BondBuyTriggerHandler{
    
    private UpdateOtherObjectRecordsRelatedToBondBuy otherRecordsFieldUpdate;
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static Boolean isTriggerAlreadyFired = false;
    
    public BondBuyTriggerHandler(boolean isExecuting, Integer size){
        
        m_isExecuting = isExecuting;
        BatchSize = size;  
        otherRecordsFieldUpdate = new UpdateOtherObjectRecordsRelatedToBondBuy();
    }
   
    public void OnBeforeInsert(List<Bond_Buy__c> newBondBuy){
        String msg = '';
        try{
            
              Map<Id,List<Bond_Buy__c>> BOfferingMap = new Map<Id,List<Bond_Buy__c>>();
               for(Bond_Buy__c bb :newBondBuy){
                if(bb.Bond_Offering__c!=Null){                	
                    List<Bond_Buy__c> handleDuplicate = BOfferingMap.get(bb.Bond_Offering__c);
                    if(handleDuplicate == null)
                        handleDuplicate = new List<Bond_Buy__c>();
                    
                    handleDuplicate.add(bb);
                    BOfferingMap.put(bb.Bond_Offering__c,handleDuplicate);
                 }
            }

            List<Bond_Offering__c> BondOfferings = [SELECT Id,Units_Pending__c,Units_Sold__c,Units_Remaining__c FROM Bond_Offering__c
                                                    WHERE Id IN: BOfferingMap.KeySet()];
                    
            for(Bond_Offering__c BOffs :BondOfferings){

               List<Bond_Buy__c> handleBonds = BOfferingMap.get(BOffs.Id);                
                Decimal pendingResult=0;
                Decimal purchasedResult=0;
                // Decimal remainingresult;
                
                for(Bond_Buy__c Bbuy : handleBonds){
                    
                    if( Bbuy.Status__c == GlobalConstants.BOND_BUY_TYPE_PENDING){

                        System.debug('Bbuy.Status__c'+Bbuy.Status__c);

                        System.debug('Bbuy.Units__c '+Bbuy.Units__c );
                        System.debug('BOffs.Units_Remaining__c '+BOffs.Units_Remaining__c );

                        if(Bbuy.Units__c > BOffs.Units_Remaining__c){ 

                            msg= 'Units are exceed than unit remaing';
                           Bbuy.adderror('Units are exceed than unit remaing');
                             System.debug('BOffs.Units_Remaining__c'+BOffs.Units_Remaining__c);
                             //throw new AuraHandledException('Units are exceed than unit remaing');
                             
                          }
                         pendingResult += Bbuy.Units__c ;
                         System.debug('pendingResult'+pendingResult);
                    }
                    else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                        purchasedResult += Bbuy.Units__c ;
                        System.debug('purchasedResult'+purchasedResult);
                        System.debug('Bbuy.Units__c'+Bbuy.Units__c);
                    }
                        System.debug('purchasedResult'+purchasedResult);
                        System.debug('BOffs.Units_Sold__c'+BOffs.Units_Sold__c);
                    if(purchasedResult +BOffs.Units_Sold__c > 1000 ){
                        
                        System.debug('BOffs.Units_Sold__c'+BOffs.Units_Sold__c);
                             msg= 'Unts Sold Should Not Exceed by 1000';
                             Bbuy.adderror('Unts Sold Should Not Exceed by 1000');      
                             //throw new AuraHandledException('Unts Sold Should Not Exceed by 1000');
                    }
                    else if((pendingResult +BOffs.Units_Pending__c) > (2 * BOffs.Units_Remaining__c )){
                                
                        System.debug('purchasedResult'+purchasedResult);
                                msg = 'Unit Pending Cannot be exceeds twice of Unit Remaining';
                                Bbuy.adderror('Unit Pending Cannot be exceeds twice of Unit Remaining');
                            // throw new AuraHandledException('Unit Pending Cannot be exceeds twice of Unit Remaining');
                    }

                 }
                    
             }   
             BOfferingMap.clear();
        }
        catch(Exception ex){
            
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnBeforeInsert',ex);
            HandleExceptionLog.saveLog();
            throw new AuraHandledException(msg);
        }
    }

     
    
    public void OnBeforeUpdate(List<Bond_Buy__c> newBondBuy,Map<ID, Bond_Buy__c> oldBondBuyMap){
        system.debug('BondBuy Trigger On Before Update');
        String msg = '';
        try{
              Map<Id,List<Bond_Buy__c>> BOfferingMap = new Map<Id,List<Bond_Buy__c>>();
               for(Bond_Buy__c bb :newBondBuy){
                if(bb.Bond_Offering__c!=Null){                	
                    List<Bond_Buy__c> handleDuplicate = BOfferingMap.get(bb.Bond_Offering__c);
                    if(handleDuplicate == null)
                        handleDuplicate = new List<Bond_Buy__c>();
                    
                    handleDuplicate.add(bb);
                    BOfferingMap.put(bb.Bond_Offering__c,handleDuplicate);
                 }
            }

            List<Bond_Offering__c> BondOfferings = [SELECT Id,Units_Pending__c,Units_Sold__c,Units_Remaining__c FROM Bond_Offering__c
                                                    WHERE Id IN: BOfferingMap.KeySet()];
              String oldStatus;

            for(Bond_Offering__c BOffs :BondOfferings){

               List<Bond_Buy__c> handleBonds = BOfferingMap.get(BOffs.Id);                
                Decimal pendingResult=0;
                Decimal purchasedResult=0;
                // Decimal remainingresult;
                
                for(Bond_Buy__c Bbuy : handleBonds){
                    
                     oldStatus = oldBondBuyMap.get(Bbuy.Id).Status__c;
                     if(oldStatus== GlobalConstants.BOND_BUY_TYPE_PURCHASED || oldStatus== GlobalConstants.BOND_BUY_TYPE_PASSED){
                                        msg = 'You Can Not Change Passed and Purchased';
                                        Bbuy.adderror('You Can Not Change Passed and Purchased');
                     }
                     else{

                            if( Bbuy.Status__c == GlobalConstants.BOND_BUY_TYPE_PENDING){

                                System.debug('Bbuy.Status__c'+Bbuy.Status__c);

                                System.debug('Bbuy.Units__c '+Bbuy.Units__c );
                                System.debug('BOffs.Units_Remaining__c '+BOffs.Units_Remaining__c );

                                if(Bbuy.Units__c > BOffs.Units_Remaining__c){ 

                                    msg= 'Units are exceed than unit remaing';
                                Bbuy.adderror('Units are exceed than unit remaing');
                                    System.debug('BOffs.Units_Remaining__c'+BOffs.Units_Remaining__c);
                                    //throw new AuraHandledException('Units are exceed than unit remaing');
                                    
                                }
                                pendingResult += Bbuy.Units__c ;
                                System.debug('pendingResult'+pendingResult);
                            }
                            else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                                purchasedResult += Bbuy.Units__c ;
                                System.debug('purchasedResult'+purchasedResult);
                                System.debug('Bbuy.Units__c'+Bbuy.Units__c);
                            }
                                System.debug('purchasedResult'+purchasedResult);
                                System.debug('BOffs.Units_Sold__c'+BOffs.Units_Sold__c);
                            if(purchasedResult +BOffs.Units_Sold__c > 1000 ){
                                
                                System.debug('BOffs.Units_Sold__c'+BOffs.Units_Sold__c);
                                    msg= 'Unts Sold Should Not Exceed by 1000';
                                    Bbuy.adderror('Unts Sold Should Not Exceed by 1000');      
                                    //throw new AuraHandledException('Unts Sold Should Not Exceed by 1000');
                            }
                            else if((pendingResult +BOffs.Units_Pending__c) > (2 * BOffs.Units_Remaining__c )){
                                        
                                System.debug('purchasedResult'+purchasedResult);
                                        msg = 'Unit Pending Cannot be exceeds twice of Unit Remaining';
                                        Bbuy.adderror('Unit Pending Cannot be exceeds twice of Unit Remaining');
                                    // throw new AuraHandledException('Unit Pending Cannot be exceeds twice of Unit Remaining');
                            }

                     }
                 }
                    
             }   
             BOfferingMap.clear();
            
        }
        catch(Exception ex){
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnBeforeUpdate',ex);
            HandleExceptionLog.saveLog();
            
            throw new AuraHandledException(msg);
        }
    }
    
    /*
    public void OnBeforeDelete(List<Bond_Buy__c> oldBondBuy){
        system.debug('BondBuy Trigger On Before Insert');
        
        try{
            for(Bond_Buy__c bb :oldBondBuy){
                if(bb.Status__c==GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                    bb.isPurchased__c=1; // this variable set to 1 so it can be used for Checking Bond Already Purchased once
                }
                else{
                    bb.isPurchased__c=0;
                }
            }
        }
        catch(Exception ex){
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnBeforeDelete',ex);
            HandleExceptionLog.saveLog();
            
        }
    }
    
    */
    public void OnAfterInsert(List<Bond_Buy__c> newBondBuy)
    {
        system.debug('BondBuy Trigger On After Insert');
        try{
            otherRecordsFieldUpdate.updateBondOfferingOnInsert(newBondBuy);
            otherRecordsFieldUpdate.updateInvestorOnInsert(newBondBuy);
            isTriggerAlreadyFired = true;
        }catch(Exception ex){
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnAfterInsert',ex);
            HandleExceptionLog.saveLog();    
        }
        
    }
    public void OnAfterUpdate( List<Bond_Buy__c> newBondBuy, List<Bond_Buy__c> oldBondBuy,  Map<ID, Bond_Buy__c> oldBondBuyMap, Map<ID, Bond_Buy__c> newBondBuyMap )
    {
        system.debug('BondBuy Trigger On After Update ');
        //here we need to write condition for update of status and unit field of BondBuy
        // https://developer.salesforce.com/forums/?id=9060G0000005VDMQA2
        try{
            
            System.debug('isTriggerAlreadyFired === '+isTriggerAlreadyFired);
           // if(!isTriggerAlreadyFired){
                //for (Bond_Buy__c newBB: newBondBuy) {  //for lopp shold not be there
                    //Bond_Buy__c oldBB = oldBondBuyMap.get(newBB.Id);
                    //if (newBB.Status__c != oldBB.Status__c || newBB.Units__c !=oldBB.Units__c) {
                        
                        otherRecordsFieldUpdate.updateBondOffering(oldBondBuyMap,newBondBuyMap);
                        otherRecordsFieldUpdate.updateInvestor(oldBondBuyMap,newBondBuyMap);
                        isTriggerAlreadyFired = true;
                    //}
                //}
            //}
        }catch(Exception ex){
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnAfterUpdate',ex);
            HandleExceptionLog.saveLog();
        }
    }
    
    public void OnAfterDelete(List<Bond_Buy__c> oldBondBuy, Map<ID, Bond_Buy__c> oldBondBuyMap){
        system.debug('BondBuy Trigger On After Delete');
        try{
            otherRecordsFieldUpdate.updateBondOfferingOnDelete(oldBondBuy,oldBondBuyMap);
            otherRecordsFieldUpdate.updateInvestorOnDelete(oldBondBuy,oldBondBuyMap);
            isTriggerAlreadyFired = true;	
        }catch(Exception ex){
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnAfterDelete',ex);
            HandleExceptionLog.saveLog();
        }
    }
    
    public void OnAfterUndelete(List<Bond_Buy__c> newBondBuy, Map<ID, Bond_Buy__c> newBondBuyMap){
        system.debug('BondBuy Trigger On After Delete');
        try{
            otherRecordsFieldUpdate.updateBondOfferingOnUndelete(newBondBuy,newBondBuyMap);
            otherRecordsFieldUpdate.updateInvestorOnUndelete(newBondBuy,newBondBuyMap);
            isTriggerAlreadyFired = true;	
        }catch(Exception ex){
            system.debug('===Exception =====' + ex);
            HandleExceptionLog.addLog('BondBuyTriggerHandler','OnAfterUndelete',ex);
            HandleExceptionLog.saveLog();
        }
        
    }
    
    
    
}