trigger BondBuyTrigger on Bond_Buy__c ( before insert,before update, after insert, after update, after delete, after undelete) {
    //after insert because we need to update related object records
    
    BondBuyTriggerHandler handler = new BondBuyTriggerHandler(Trigger.isExecuting, Trigger.size); //isExecuting Returns true if the current context for the Apex code is a trigger
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.OnBeforeInsert(trigger.New);
        }
        
        if(Trigger.isUpdate){
            handler.OnBeforeUpdate(trigger.New,Trigger.OldMap);   
        }
        /*
        if(Trigger.isDelete){
            handler.OnBeforeDelete(trigger.New);   
        }
         */
        
    }
    //else 
       
        if (Trigger.isAfter){
        
      	  if(Trigger.isInsert){
            
            handler.OnAfterInsert(trigger.New);
     	   }   
          else if(Trigger.isUpdate){
            handler.OnAfterUpdate(trigger.New, trigger.Old, Trigger.OldMap, Trigger.NewMap);                
          }
          else if (Trigger.isDelete){
            handler.OnAfterDelete(trigger.Old, Trigger.OldMap);   
          }
          else if(Trigger.isUndelete){
            handler.OnAfterUndelete(trigger.New, Trigger.NewMap);  
          }
        
      }
    
    
    
}