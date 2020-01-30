({
    refreshView: function(component, event) {
        // refresh the view
    
        eval( "$A.get('e.force:refreshView').fire();");
    },

    navigationAura : function(component, event, helper) {
         
        var recId = event.getParam('value');
        
                        // eslint-disable-next-line no-console
                        console.log('navigate To value in c '+recId); 
        component.find("navId").navigate({
            type: 'standard__recordPage',
            attributes: {
                recordId : recId, // Hardcoded record id from given objectApiName
                actionName: 'edit',  //Valid values include clone, edit, and view.
                objectApiName: 'Bond_Offering__c' //The API name of the record’s object
            }}, true);
            eval( "$A.get('e.force:refreshView').fire();");
                        // eslint-disable-next-line no-console
                        console.log('navigate To value '+recId); 
    }

})