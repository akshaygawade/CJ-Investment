public with sharing class CreateBondBuy {

  @AuraEnabled
    public static void createBB(String data){
        try {
       	System.debug('Data passed='+data);

        List<Bond_Buy__c> bbList = (List<Bond_Buy__c>)JSON.deserialize(data, List<Bond_Buy__c>.class);
        
        System.debug('Updated Data passed='+bbList);
        insert bbList;
        bblist.clear();
        //return bbList;
        }catch(Exception ex) {
            
            throw new AuraHandledException(ex.getMessage());

        }
      
    }
        @AuraEnabled
    public static void deleteBondBuy(list<Id> lstbondIds){
        try {
            list<Bond_Buy__c> lstBondToDelete = new list<Bond_Buy__c>();
            
            for(Id idBond : lstbondIds) {
                lstBondToDelete.add(new Bond_Buy__c(Id = idBond));
            }
            if(!lstBondToDelete.isEmpty()) {
                delete lstBondToDelete;
            }
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

      @AuraEnabled
    public static void updateBondBuy(String data){
        try {
            
       	System.debug('Data passed='+data);

        List<Bond_Buy__c> bbList = (List<Bond_Buy__c>)JSON.deserialize(data, List<Bond_Buy__c>.class);
        
        System.debug('Updated Data passed='+bbList);
            if(!bbList.isEmpty()) {
                Update bbList;
            }
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    
}