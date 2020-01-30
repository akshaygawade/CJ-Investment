public with sharing class BondOffering_PageBottomController {
   /*
    @AuraEnabled(cacheable=true)
    public static List<Bond_Buy__c> getBondBuyList(String selectedOption, Id recId) {
System.debug('recId'+recId);
        if(recId!=null){
                if(selectedOption.equalsIgnoreCase('AnyType')){
                    List<Bond_Buy__c> bonds = [SELECT Units__c, Status__c, Investor__r.Name,Investor__r.Type__c FROM Bond_Buy__c WHERE Bond_Offering__r.Id=:recId];
                
                    return bonds;
                }   

                else{
                    List<Bond_Buy__c> bonds= [SELECT Units__c,Status__c, Investor__r.Name, Investor__r.Type__c FROM Bond_Buy__c WHERE Investor__r.Type__c=:selectedOption AND Bond_Offering__r.Id=:recId];

            
                    return bonds;
                }
        }
        else{

            
                if(selectedOption.equalsIgnoreCase('AnyType')){
                            List<Bond_Buy__c> bond = [SELECT Investor__r.Id FROM Bond_Buy__c];

                            Set<Id> s1 = new Set<Id>();
                                   
                            for(Integer i=0;i<bond.size()-1;i++){
                                    s1.add(bond[i].Investor__r.Id);
                            }                         
                            List<Investor__c> inv = [SELECT Id, Name, Type__c ,Default_Bond_Units__c FROM Investor__c WHERE Id NOT IN :s1];
                            List<Bond_Buy__c> newbond =new  List<Bond_Buy__c>();
                    
                    if(!inv.isEmpty()){
                        for(Integer i=0;i<inv.size()-1;i++){
                             Bond_Buy__c b= new Bond_Buy__c();
                            b.Units__c=inv[i].Default_Bond_Units__c;
                            b.Status__c='New';
                            b.Investor__c=inv[i].Id;
                         //   b.Investor__r.Name =inv[i].Name;
                         //   b.Investor__r.Type__c=inv[i].Type__c;
                            newbond.add(b);
                        }
                        
                    }
                    

                        return newbond;
                }
                else{
                          List<Bond_Buy__c> bond = [SELECT Investor__r.Id FROM Bond_Buy__c];

                            Set<Id> s1 = new Set<Id>();
                                   
                            for(Integer i=0;i<bond.size()-1;i++){
                                    s1.add(bond[i].Investor__r.Id);
                            } 
                            List<Investor__c> inv = [SELECT Id, Name, Type__c,Default_Bond_Units__c FROM Investor__c WHERE Id NOT IN :s1 AND  Type__c=:selectedOption];
                            List<Bond_Buy__c> newbond = new List<Bond_Buy__c>();
                    
                    if(!inv.isEmpty()){
                        for(Integer i=0;i<inv.size()-1;i++){
                             Bond_Buy__c b= new Bond_Buy__c();
                            b.Units__c=inv[i].Default_Bond_Units__c;
                            b.Status__c='New';
                            b.Investor__c=inv[i].Id;
                           // b.Investor__r.Name =inv[i].Name;
                            //b.Investor__r.Type__c=inv[i].Type__c;
                            newbond.add(b);
                        }
                        
                    }
                    

                        return newbond;

                }
        
        }
   
    }*/




    //public List<Bond_Offering__c> BondOfferList = new List<Bond_Offering__c>([SELECT  Id, Name, units_pending__c, units_sold__c FROM Bond_Offering__c LIMIT 1 ]);

    @AuraEnabled (cacheable=true)
    public static List<WrapBondBuyAndInvestors> getBondBuyList(String selectedOption, Id recId, Integer refvalue){
        // List of Investor and Bond Buy Objects.
        System.debug('refresh value'+ refvalue);
        Id BondOfferId = recId;
        String Type=  selectedOption;

       List<Investor__c> investorList ;
        if(Type !='AnyType'){
            investorList = new List<Investor__c>([SELECT  Id, Name, Type__c FROM Investor__c WHERE Type__c =: Type]);
          
        }else
        {
            investorList = new List<Investor__c>([SELECT  Id, Name, Type__c FROM Investor__c] );
        }
        
        List<Bond_Buy__c> bondBuyList = new List<Bond_Buy__c> ([SELECT units__c,status__c, Investor__c  FROM Bond_Buy__c WHERE Bond_Offering__c =: BondOfferId]);
       
        //create a List to store Wrapper Data
         List<WrapBondBuyAndInvestors> WrapList =new List<WrapBondBuyAndInvestors> ();
         Set<Id> investorId=new Set<Id>();
        
         // getting the investor data for the curren bond Offering data
        for(Bond_Buy__c bond: bondBuyList){
            for(Investor__c investor:investorList){

                if(bond.Investor__c == investor.Id){
                    WrapBondBuyAndInvestors wrapData= new WrapBondBuyAndInvestors(String.valueOf(bond.units__c),investor.Name,bond.Status__c,investor.Type__c,bond.Id,investor.Id,BondOfferId);
                    WrapList.add(wrapData);
                    investorId.add(investor.Id);
                }
            }
        } 
	
		List<Investor__c> newInvestorList;        
        if(Type != 'AnyType'){
            // Get the Investor List with new Status
              newInvestorList = new List<Investor__c>([SELECT  Id, Name, Type__c,Default_Bond_Units__c FROM Investor__c WHERE Id NOT IN :investorId AND Type__c =: Type] );
    
        }else{
            // Get the Investor List with new Status
              newInvestorList = new List<Investor__c>([SELECT  Id, Name, Type__c,Default_Bond_Units__c FROM Investor__c WHERE Id NOT IN :investorId ] );
    
        }
         // add list to Wrapper data
         for (Investor__c investor : newInvestorList) {
            WrapBondBuyAndInvestors wrapData = new WrapBondBuyAndInvestors(String.valueOf(investor.Default_Bond_Units__c),investor.Name,'New',investor.Type__c,investor.Id,investor.Id,BondOfferId);
            WrapList.add(wrapData);
            
        }
        // Display WrapperList
        return WrapList;

    }

// This is A Wrapper Class---------->

    public class WrapBondBuyAndInvestors {
      @AuraEnabled public String Units;
      @AuraEnabled public String Name; //investor name
      @AuraEnabled public String Status;
      @AuraEnabled public String Type;
	  @AuraEnabled public Id Id;
      @AuraEnabled public Id InvestorId;
      @AuraEnabled public Id BondOfferId;
        
        WrapBondBuyAndInvestors(String Units, String Name, String Status, String Type, Id Id, Id InvestorId, Id BondOfferId ){
           this.Units=Units;
           this.Name=Name;
           this.Status=Status;
           this.Type=Type;
            this.Id=Id;
            this.InvestorId=InvestorId;
            this.BondOfferId=BondOfferId;
       }
}


}