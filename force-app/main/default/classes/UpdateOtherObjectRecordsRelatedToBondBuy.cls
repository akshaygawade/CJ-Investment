public with sharing class UpdateOtherObjectRecordsRelatedToBondBuy {
    
    public UpdateOtherObjectRecordsRelatedToBondBuy() {
        
    }
    /**
* @Description : This method is responsible to update the Bond Offering "Units_Pending__c,Units_Sold__c" fields when Bond Buy Status and Unit fields are  updated on the Bond Buy  
* @param   : oldBondBuyMap, newBondBuyMap
*/
    public  void updateBondOffering( Map<ID, Bond_Buy__c> oldBondBuyMap,Map<ID, Bond_Buy__c> newBondBuyMap){
        
        //Map<Id,Bond_Buy__c> BOfferingMap = new Map<Id,Bond_Buy__c>(); 
        Map<Id,List<Bond_Buy__c>> BOfferingMap = new Map<Id,List<Bond_Buy__c>>();
        
        try{
            
            for(Bond_Buy__c bb :newBondBuyMap.values()){
                
                if(bb.Bond_Offering__c!=Null){
                    
                    List<Bond_Buy__c> handleDuplicate = BOfferingMap.get(bb.Bond_Offering__c);
                    if(handleDuplicate == null)
                        handleDuplicate = new List<Bond_Buy__c>();
                    
                    handleDuplicate.add(bb);
                    BOfferingMap.put(bb.Bond_Offering__c,handleDuplicate);
                    
                  //  BOfferingMap.put(bb.Bond_Offering__c, bb); //All BondOffering Put in map
                
                }
            }
            
            
            //use map
            List<Bond_Offering__c> BondOfferings = [SELECT Id,Units_Pending__c,Units_Sold__c FROM Bond_Offering__c
                                                    WHERE Id IN: BOfferingMap.KeySet()];  //here return Bond Offering related to Bond Buy
            
            List<Bond_Offering__c> UpdatedBondOfferings=  new List<Bond_Offering__c>();
            
            
            //All Updated Changes will carried Out in Below Changes
            //
            
            Decimal oldBondBuyUnits;
            Decimal newBondBuyUnits;
            String oldStatus;
            
            for(Bond_Offering__c BOffs :BondOfferings){
                
                //Bond_Buy__c Bbuy = BOfferingMap.get(BOffs.Id);
                Decimal Pending = BOffs.Units_Pending__c; //this is used because multiple operation on this units
                Decimal Sold = BOffs.Units_Sold__c;

                List<Bond_Buy__c> handleBonds = BOfferingMap.get(BOffs.Id);
                
                  
                for(Bond_Buy__c Bbuy : handleBonds){
                    
                    oldBondBuyUnits = oldBondBuyMap.get(Bbuy.Id).Units__c;
                    newBondBuyUnits = newBondBuyMap.get(Bbuy.Id).Units__c;
                    oldStatus = oldBondBuyMap.get(Bbuy.Id).Status__c;
                    //we have to take previous status also
           
                    if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PENDING && oldStatus== GlobalConstants.BOND_BUY_TYPE_PENDING){ //pending-->pending
                        
                        if(oldBondBuyUnits>newBondBuyUnits ){
                            Pending -= (oldBondBuyUnits - newBondBuyUnits);
                        }
                        else if(oldBondBuyUnits<newBondBuyUnits ){
                            Pending += (newBondBuyUnits - oldBondBuyUnits);
                        }   
                    }
                    else if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PENDING && oldStatus== GlobalConstants.BOND_BUY_TYPE_PURCHASED){ //purchased-->pending ?
                        
                        	Pending += newBondBuyUnits;//hee we changed only pending bcoz once once purchased never decline
                        
                    }
                    else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED && oldStatus== GlobalConstants.BOND_BUY_TYPE_PURCHASED){ //purchased-->purchased
                        
                        if(oldBondBuyUnits>newBondBuyUnits){
                            Sold -= (oldBondBuyUnits - newBondBuyUnits);
                        }
                        else if(oldBondBuyUnits<newBondBuyUnits){
                            Sold += (newBondBuyUnits - oldBondBuyUnits);
                        }
                    }
                    else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED && oldStatus== GlobalConstants.BOND_BUY_TYPE_PENDING){ //pending --> purchased
                        
                        if(oldBondBuyUnits>newBondBuyUnits){
                            Pending -= (oldBondBuyUnits - newBondBuyUnits);
                            Sold += newBondBuyUnits;
                        }else{
                            Pending -= oldBondBuyUnits;
                            Sold += newBondBuyUnits;
                        }
                    }
                    else if(oldStatus== GlobalConstants.BOND_BUY_TYPE_PASSED) { //passed -->pending/purchased
                        
                        if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                            Sold += newBondBuyUnits;
                            
                        }
                        else if((Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PENDING)) {
                            Pending += newBondBuyUnits;
                        }
                    }
                    else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PASSED && oldStatus== GlobalConstants.BOND_BUY_TYPE_PENDING){ //pending --> purchased
                        
                        if(oldBondBuyUnits>newBondBuyUnits){
                            Pending -= (oldBondBuyUnits - newBondBuyUnits);
                         
                        }else{
                            Pending -= oldBondBuyUnits;
                         
                        }
                    }
                }
                BOffs.Units_Pending__c =  Pending; //this is used because multiple operation on this units
                BOffs.Units_Sold__c=  Sold;
                
                UpdatedBondOfferings.add(BOffs);
            }
            
            
            if(UpdatedBondOfferings.size()>0){  
                
                UPDATE UpdatedBondOfferings;
                BOfferingMap.clear();
                UpdatedBondOfferings.clear();
                BondOfferings.clear();
            }
            
        }
        catch(Exception ex){
            
            System.debug('Exception In UpdateBond Offering:'+ ex);
            HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateBondOffering',ex);
            HandleExceptionLog.saveLog(); 
        }
        
    }
    
    /**
* @Description : This method is responsible to update the Investor "Bonds_Pitched__c,Bonds_Purchased__c  " fields when Bond Buy Status and Unit fields are  updated on the Bond Buy  
* @param   : oldBondBuyMap, newBondBuyMap
*/
    public void updateInvestor(Map<ID, Bond_Buy__c> oldBondBuyMap,Map<ID, Bond_Buy__c> newBondBuyMap){
        
		Map<Id,List<Bond_Buy__c>> InvestorMap = new Map<Id,List<Bond_Buy__c>>();
        
        try{
            for(Bond_Buy__c bb :newBondBuyMap.values()){
                
                if(bb.Investor__c!=Null){
                    List<Bond_Buy__c> handleDuplicate = InvestorMap.get(bb.Investor__c);
                    if(handleDuplicate == null)
                        handleDuplicate = new List<Bond_Buy__c>();
                    
                    handleDuplicate.add(bb);
                    InvestorMap.put(bb.Investor__c, handleDuplicate);
                  //  InvestorMap.put(bb.Investor__c, bb); //All Investor Put in map
                }
            }
            
            List<Investor__c> Investors = [SELECT Id,Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c
                                           WHERE Id IN: InvestorMap.KeySet()];  //here return Bond Offering related to Bond Buy
            
            List<Investor__c> UpdatedInvestors=  new List<Investor__c>();
            
            String oldStatus ;
            
            //All Updated Changes will carried Out in Below Changes
            for(Investor__c Invst :Investors){
                
            //    Bond_Buy__c Bbuy = InvestorMap.get(Invst.Id);
            
                List<Bond_Buy__c> handleBonds = InvestorMap.get(Invst.Id);
                
                for(Bond_Buy__c Bbuy : handleBonds){
                    
                    oldStatus = oldBondBuyMap.get(Bbuy.Id).Status__c;
                    
                    if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED && (oldStatus==GlobalConstants.BOND_BUY_TYPE_PASSED || oldStatus == GlobalConstants.BOND_BUY_TYPE_PENDING)){
                        
                        Invst.Bonds_Purchased__c += 1; //this should be updated only once per Investor
                    }
               }
                UpdatedInvestors.add(Invst);
                
            }
            
            if(!UpdatedInvestors.isEmpty()){
                UPDATE UpdatedInvestors;
                InvestorMap.clear();
                UpdatedInvestors.clear();
                Investors.clear();
            }
        }catch(Exception ex){  
            System.debug('Exception In Update Investor:'+ ex);
            HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateInvestor',ex);
            HandleExceptionLog.saveLog(); 
        }
        
    }
    
    
    
    /**
* @Description : This method is responsible to insert the Bond Offering "Units_Pending__c,Units_Sold__c" fields when Bond Buy Status and Unit fields are  updated on the Bond Buy  
* @param   : oldBondBuyMap, newBondBuyMap
*/
    public void updateBondOfferingOnInsert(List<Bond_buy__c> newBondBuy){
        
        
        Map<Id,List<Bond_Buy__c>> BOfferingMap = new Map<Id,List<Bond_Buy__c>>();
        
       // Map<Id,Bond_Buy__c> BOfferingMap = new Map<Id,Bond_Buy__c>();
        
        try{
            
            for(Bond_Buy__c bb :newBondBuy){
                if(bb.Bond_Offering__c!=Null){
                	
                    List<Bond_Buy__c> handleDuplicate = BOfferingMap.get(bb.Bond_Offering__c);
                    if(handleDuplicate == null)
                        handleDuplicate = new List<Bond_Buy__c>();
                    
                    handleDuplicate.add(bb);
                    BOfferingMap.put(bb.Bond_Offering__c,handleDuplicate);
                    
                  //  BOfferingMap.put(bb.Bond_Offering__c, bb); //All BondOffering Put in map
                
                }
            }
            
            List<Bond_Offering__c> BondOfferings = [SELECT Id,Units_Pending__c,Units_Sold__c FROM Bond_Offering__c
                                                    WHERE Id IN: BOfferingMap.KeySet()];  //here return Bond Offering related to Bond Buy
            
            List<Bond_Offering__c> UpdatedBondOfferings=  new List<Bond_Offering__c>();
            
            for(Bond_Offering__c BOffs :BondOfferings){
                
                //Bond_Buy__c Bbuy = BOfferingMap.get(BOffs.Id); //list should br taken
                
                List<Bond_Buy__c> handleBonds = BOfferingMap.get(BOffs.Id);
                
                for(Bond_Buy__c Bbuy : handleBonds){
                    if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PENDING){
                        BOffs.Units_Pending__c += Bbuy.Units__c ;
                    }
                    else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                        BOffs.Units_Sold__c += Bbuy.Units__c ;
                    }
                }
                UpdatedBondOfferings.add(BOffs);
            }
            
            if(!UpdatedBondOfferings.isEmpty()){
                UPDATE UpdatedBondOfferings;
            	BOfferingMap.clear();
                UpdatedBondOfferings.clear();
                BondOfferings.clear();
            }
            
        }catch(Exception ex){
            System.debug('Exception In Update Bond Offering Insert:'+ ex); 
            HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateBondOfferingOnInsert',ex);
            HandleExceptionLog.saveLog(); 
        }
        
        
        
        
    }
    
    public void updateInvestorOnInsert(List<Bond_buy__c> newBondBuy){
        
        Map<Id,List<Bond_Buy__c>> InvestorMap = new Map<Id,List<Bond_Buy__c>>();
		try{
            
            for(Bond_Buy__c bb :newBondBuy){
                if(bb.Investor__c!=Null){
                    
                    List<Bond_Buy__c> handleDuplicate = InvestorMap.get(bb.Investor__c);
                    if(handleDuplicate == null)
                        handleDuplicate = new List<Bond_Buy__c>();
                    
                    handleDuplicate.add(bb);
                    InvestorMap.put(bb.Investor__c, handleDuplicate);
                  //  InvestorMap.put(bb.Investor__c, bb); //All Investor Put in map
                }
            }
            
            List<Investor__c> Investors = [SELECT Id,Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c
                                           WHERE Id IN: InvestorMap.KeySet()];  //here return Bond Offering related to Bond Buy
            
            List<Investor__c> UpdatedInvestors=  new List<Investor__c>(); //for update
                
            
            for(Investor__c Invst :Investors){
                
                //Bond_Buy__c Bbuy = InvestorMap.get(Invst.Id);
                List<Bond_Buy__c> handleBonds = InvestorMap.get(Invst.Id);
                
                for(Bond_Buy__c Bbuy : handleBonds){
                    Invst.Bonds_Pitched__c +=1;  //this should be updated with any status 
                    
                    if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                        Invst.Bonds_Purchased__c += 1; //this should be updated only once per Investor
                    }
                }
                
                UpdatedInvestors.add(Invst);
            }
            
            if(!UpdatedInvestors.isEmpty()){
                UPDATE UpdatedInvestors;
                InvestorMap.clear();
                UpdatedInvestors.clear();
                Investors.clear();
            }
            
            
        }catch(Exception ex){
              System.debug('Exception on Update Investor on Insert:'+ ex);
              HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateInvestorOnInsert',ex);
              HandleExceptionLog.saveLog();
            
        }
    }
    //////below this duplicate bondOfferings needs to handle
    public void updateBondOfferingOnDelete(List<Bond_Buy__c> oldBondBuy, Map<ID, Bond_Buy__c> oldBondBuyMap){
        
        try{
            Map<Id,Bond_Buy__c> BOfferingMap = new Map<Id,Bond_Buy__c>();
            
            for(Bond_Buy__c bb :oldBondBuyMap.values()){
                if(bb.Bond_Offering__c!=Null){
                    BOfferingMap.put(bb.Bond_Offering__c, bb); //All BondOffering Put in map
                }
            }
            List<Bond_Offering__c> BondOfferings = [SELECT Id,Units_Pending__c,Units_Sold__c FROM Bond_Offering__c
                                                    WHERE Id IN: BOfferingMap.KeySet()];  //here return Bond Offering related to Bond Buy
            
            List<Bond_Offering__c> UpdatedBondOfferings=  new List<Bond_Offering__c>();
            
            for(Bond_Offering__c BOffs :BondOfferings){
                
                Bond_Buy__c Bbuy = BOfferingMap.get(BOffs.Id);
                if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PENDING){
                    BOffs.Units_Pending__c -= Bbuy.Units__c ;  
                }
                else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                    BOffs.Units_Sold__c -= Bbuy.Units__c ;
                }
                UpdatedBondOfferings.add(BOffs);
            }
            
            if(!UpdatedBondOfferings.isEmpty()){
                UPDATE UpdatedBondOfferings;
                BOfferingMap.clear();
                UpdatedBondOfferings.clear();
                BondOfferings.clear();
            }
        }
        catch(Exception ex){
              System.debug('Exception In Delete BondBuy and Update Bond Offering :'+ ex);
              HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateBondOfferingOnDelete',ex);
              HandleExceptionLog.saveLog();
            
        }
    }
    public void updateInvestorOnDelete(List<Bond_Buy__c> oldBondBuy, Map<ID, Bond_Buy__c> oldBondBuyMap){
        
        try{
            
            Map<Id,Bond_Buy__c> InvestorMap = new Map<Id,Bond_Buy__c>();     
            
            for(Bond_Buy__c bb :oldBondBuy){
                if(bb.Investor__c!=Null){
                    InvestorMap.put(bb.Investor__c, bb); //All Investor Put in map
                }
            }
            List<Investor__c> Investors = [SELECT Id,Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c
                                           WHERE Id IN: InvestorMap.KeySet()];  //here return Investor related to Bond Buy
            
            List<Investor__c> UpdatedInvestors=  new List<Investor__c>(); //for update
            
            
            for(Investor__c Invst :Investors){
                Bond_Buy__c Bbuy = InvestorMap.get(Invst.Id);
                Invst.Bonds_Pitched__c -=1;  //this should be updated with any status 
                
                if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                    Invst.Bonds_Purchased__c -= 1; //this should be updated only once per Investor 
                }
                UpdatedInvestors.add(Invst);
            }
            
            if(!UpdatedInvestors.isEmpty()){
                UPDATE UpdatedInvestors;
                InvestorMap.clear();
                UpdatedInvestors.clear();
                Investors.clear();
                
            }
        }
        catch(Exception ex){
            System.debug('Exception In Delete BondBuy and Update Investor :'+ ex);
            HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateInvestorOnDelete',ex);
            HandleExceptionLog.saveLog();
        }
    }
    
    
    public void updateBondOfferingOnUndelete(List<Bond_Buy__c> newBondBuy, Map<ID, Bond_Buy__c> newBondBuyMap){
        try{
            
            
            Map<Id,Bond_Buy__c> BOfferingMap = new Map<Id,Bond_Buy__c>();
            
            for(Bond_Buy__c bb :newBondBuyMap.values()){
                if(bb.Bond_Offering__c!=Null){
                    BOfferingMap.put(bb.Bond_Offering__c, bb); //All BondOffering Put in map
                }
            }
            List<Bond_Offering__c> BondOfferings = [SELECT Id,Units_Pending__c,Units_Sold__c FROM Bond_Offering__c
                                                    WHERE Id IN: BOfferingMap.KeySet()];  //here return Bond Offering related to Bond Buy
            List<Bond_Offering__c> UpdatedBondOfferings=  new List<Bond_Offering__c>();
            
            for(Bond_Offering__c BOffs :BondOfferings){
                
                Bond_Buy__c Bbuy = BOfferingMap.get(BOffs.Id);
                
                if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PENDING){
                    BOffs.Units_Pending__c += Bbuy.Units__c ;  
                }
                else if(Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                    BOffs.Units_Sold__c += Bbuy.Units__c ;
                }
                UpdatedBondOfferings.add(BOffs);
            }
            if(!UpdatedBondOfferings.isEmpty()){
                UPDATE UpdatedBondOfferings;
                BOfferingMap.clear();
                UpdatedBondOfferings.clear();
                BondOfferings.clear();
            }
        }
        catch(Exception ex){
            System.debug('Exception In Undelete Investor and Update Bond Offering:'+ ex);
            HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateBondOfferingOnUndelete',ex);
            HandleExceptionLog.saveLog();
        }
    }
    
    public void updateInvestorOnUndelete(List<Bond_Buy__c> newBondBuy, Map<ID, Bond_Buy__c> newBondBuyMap){
        
        try{
            Map<Id,Bond_Buy__c> InvestorMap = new Map<Id,Bond_Buy__c>();     
            
            for(Bond_Buy__c bb :newBondBuy){
                if(bb.Investor__c!=Null){
                    InvestorMap.put(bb.Investor__c, bb); //All Investor Put in map
                }
            }
            List<Investor__c> Investors = [SELECT Id,Bonds_Pitched__c,Bonds_Purchased__c FROM Investor__c
                                           WHERE Id IN: InvestorMap.KeySet()];  //here return Investor related to Bond Buy
            List<Investor__c> UpdatedInvestors=  new List<Investor__c>(); //for update
          
            for(Investor__c Invst :Investors){
                Bond_Buy__c Bbuy = InvestorMap.get(Invst.Id);
                Invst.Bonds_Pitched__c +=1;  //this should be updated with any status 
                
                if( Bbuy.Status__c== GlobalConstants.BOND_BUY_TYPE_PURCHASED){
                    Invst.Bonds_Purchased__c += 1; //this should be updated only once per Investor     
                }
                UpdatedInvestors.add(Invst);
                
            }  
            if(!UpdatedInvestors.isEmpty()){
                UPDATE UpdatedInvestors;
                InvestorMap.clear();
                UpdatedInvestors.clear();
                Investors.clear();
            }
         
        }
        catch(Exception ex){
            System.debug('Exception In Undelete Investor and Update Investor:'+ ex);
            HandleExceptionLog.addLog('UpdateOtherObjectRecordsRelatedToBondBuy','updateInvestorOnUndelete',ex);
            HandleExceptionLog.saveLog();
            
        }
        
    }
    
}