import {LightningElement, track, wire,api} from 'lwc';
//import { updateRecord } from 'lightning/uiRecordApi';
//import { createRecord } from 'lightning/uiRecordApi';
import  createBonds  from '@salesforce/apex/CreateBondBuy.createBB';
import  updateBonds  from '@salesforce/apex/CreateBondBuy.updateBondBuy';
import  deleteBonds  from '@salesforce/apex/CreateBondBuy.deleteBondBuy';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOppdata from '@salesforce/apex/BondOffering_PageBottomController.getBondBuyList';
//import { getRecord } from 'lightning/uiRecordApi';
//import BOND_ID from '@salesforce/schema/Bond_Buy__c.Id'
import ID from "@salesforce/schema/Bond_Buy__c.Id";
import UNITS from "@salesforce/schema/Bond_Buy__c.Units__c";
import STATUS from "@salesforce/schema/Bond_Buy__c.Status__c";
import BOND_BUY_INVESTOR_NAME from "@salesforce/schema/Bond_Buy__c.Investor__c";
import BOND_BUY_BOND_OFFERING_ID from "@salesforce/schema/Bond_Buy__c.Bond_Offering__c";
//import LightningDatatable from 'lightning/datatable';
// Datatable Columns


// row actions
const actions = [
    { label: 'Delete', name: 'delete'}
];
const columns = [
  {
        label: 'Units',
        fieldName: 'Units',
        type: 'number',
        editable:true, 
        cellAttributes: { alignment: 'left' }
    }, {
        label: 'Status',
        fieldName: 'Status',
        type: 'text',
        editable:true,
        cellAttributes: { alignment: 'left' }
    }, {
        label: 'Investor Name',
        fieldName: 'Name',     //here Investor.name
        type: 'text',
        cellAttributes: { alignment: 'left' }
    }, {
        label: 'Type',
        fieldName: 'Type',  //Investor.Type__c
        type: 'text',
        cellAttributes: { alignment: 'left' }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];
export default class bondOffering_PageBottom extends LightningElement { 
    counter = 0;
@api recordId ;
@track selectedValue='AnyType';
@track swapvalue = 1;
@track error;
@track page = 1; //this is initialize for 1st page
@track items = []; //it contains all the records.
@track data = []; //data to be display in the table
@track columns; //holds column info.
@track startingRecord = 1; //start record position per page
@track endingRecord = 0; //end record position per page
@track pageSize = 4; //default value we are assigning
@track totalCount = 0; //total record count received from all retrieved records
@track totalPage = 0; //total number of page is needed to display all records
@track draftValues=[];      
@track Id;
@track selectedRow=[];  
@track timeoutId ;
wiredResult;
investorIdData=[];
investorNameData=[];
bondOffId;
investorId;
draftData=[]; 
@track bondBuyRecord = {   //For record creation
    Id: ID,
    Units__c: UNITS,
    Status__c: STATUS,
    Investor__c: BOND_BUY_INVESTOR_NAME,
    Bond_Offering__c: BOND_BUY_BOND_OFFERING_ID
};

bondBuysList = [];


//temp draft values
    @wire(getOppdata,{selectedOption:'$selectedValue',recId:'$recordId',refvalue:'$swapvalue'})
    opp({error, data}) {
        if(data) {
           this.wiredResult=data;
           this.items = data;
           this.totalRecordCount = data.length; 
           this.totalPage = Math.ceil(this.totalRecordCount / this.pageSize);
            this.data = this.items.slice(0,this.pageSize);
           let selectedIds=[];

           
           for(let i=0;i<this.items.length;i++){

            this.investorIdData.push(this.items[i].InvestorId);
        }
           for(let i=0;i<this.data.length;i++){

               this.bondOffId=data[i].BondOfferId;

              // this.investorIdData.push(this.data[i].InvestorId);
               this.investorNameData.push(this.data[i].Name);
               if(this.data[i].Status==='Purchased' || this.data[i].Status==='Pending' || this.data[i].Status==='Passed'){
                   selectedIds.push(data[i].Id);
                   this.selectedRow= selectedIds;
                   this.count=this.selectedRow.length;
               }                    
           }
                this.totalCount=data.length;
                this.totalPage=Math.ceil(this.totalCount / this.pageSize);
                this.data=this.items.slice(0,this.pageSize);
                this.endingRecord=this.pageSize;
                this.columns=columns;
                this.error=undefined;
               // if(this.counter>0){
                //this.dispatchEvent(new CustomEvent('tablechange'));
                //}
                this.counter++;
        }
        else if(error){
                 this.error=error;
                 this.data=undefined;
           }

    }
    
    swapU(){   //this is for table refresh
        if(this.swapvalue===1){
            this.swapvalue=0;
        }
        else{
            this.swapvalue=1;
        }
        
         // eslint-disable-next-line no-console
         console.log('Sawap in Swap U'+this.swapvalue);
       this.dispatchEvent(new CustomEvent('tablechange',{ bubbles: true }));
       // clearTimeout(this.timeoutId); // no-op if invalid id 
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        //this.timeoutId = setTimeout(this.handleSwapU.bind(this), 500); // Adjust as necessary
     
    }
    handleSwapU(){  
        // eslint-disable-next-line no-console
        console.log('this.swapvalue in Swap u'+this.swapvalue);
       this.dispatchEvent(new CustomEvent('tablechange',{ bubbles: true }));
        
         // eslint-disable-next-line no-console
         console.log('this.swapvalue SWAPU2'+this.swapvalue);
    }

    swapC(){   
         // eslint-disable-next-line no-console
         console.log('this.swapvalue'+this.swapvalue);
         if(this.swapvalue===1){
             this.swapvalue=0; 
         }
         else{
             this.swapvalue=1;
         }
        //this is for table refresh
        clearTimeout(this.timeoutId); // no-op if invalid id 
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeoutId = setTimeout(this.handleSwapC.bind(this), 500); // Adjust as necessary
       // this.dispatchEvent(new CustomEvent('newbondcreated'));
    }
    handleswapC(){

         // eslint-disable-next-line no-console
         console.log('this.swapvalue SWAPC'+this.swapvalue);
       
       //  window.clearTimeout(this.delayTimeout);
         // eslint-disable-next-line @lwc/lwc/no-async-operation
            // this.delayTimeout = setTimeout(() => {
            //this.dispatchEvent(new CustomEvent('newbondcreated'));
      //   }, 2000);

      //  this.dispatchEvent(new CustomEvent('newbondcreated'));
         // eslint-disable-next-line no-console
         console.log('this.swapvalue SWAPC2'+this.swapvalue);
       
    }



    previousHandler(){
            if(this.page > 1){
                this.page=this.page-1;
                this.displayRecordPerPage(this.page);
            }

    }

    nextHandler(){
     if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page=this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    firstHandler(){
        if(this.page > 1){
            this.page=1;
            this.displayRecordPerPage(this.page);
       }
    }

    lastHandler(){
        if((this.page < this.totalPage) && this.page !== this.totalPage){
            this.page=this.totalPage;
            this.displayRecordPerPage(this.page);
        }
    }
        
    displayRecordPerPage(page){
        this.startingRecord=((page-1) * this.pageSize);       
        this.endingRecord=(this.pageSize * page);
        this.endingRecord=(this.endingRecord > this.totalCount) ? this.totalCount : this.endingRecord;
        this.data=this.items.slice(this.startingRecord,this.endingRecord);
        let selectedIds=[];  //for selected row

        for(let i=0;i<this.data.length;i++){
            if(this.data[i].Status==='Purchased'|| this.data[i].Status==='Passed'){
                selectedIds.push(this.data[i].Id);
                this.selectedRow= selectedIds;
                //this.selectedRow.editable=false;        
                this.count=this.selectedRow.length;
            }                    
        }
        this.startingRecord=this.startingRecord + 1;
    }
    

    get comboboxOption() {
        return [
            { label: 'Pensions', value: 'pensions' },
            { label: 'Universities', value: 'universities' },
            { label: 'Municipalities', value: 'municipalities' },
            { label: 'Hedge Funds', value: 'Hedge' },
            { label: 'Any Type', value: 'AnyType' }
        ];
    }

    handleComboboxChange(event) {
         // Get the string of the "value" attribute on the selected option
         this.selectedValue = event.detail.value;
         const filterChangeEvent = new CustomEvent('filterchange', {detail:this.selectedValue});
         this.dispatchEvent(filterChangeEvent);
         // Fire the custom event
         }
  
     handleCellChange(event){
            for(let i=0;i<event.detail.draftValues.length;i++){
                this.draftData.push(event.detail.draftValues[i]);
            }
     }
    
     handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
         if(actionName==='delete') {
                this.deleteCons(row);
         }
    }




    
    deleteCons(currentRow) {
        let currentRecord = [];
        currentRecord.push(currentRow.Id);
     //   this.showLoadingSpinner = true;

        // calling apex class method to delete the selected contact
        deleteBonds({lstbondIds: currentRecord})
        .then(result => {
            window.console.log('result ====> ' + result);
           // this.showLoadingSpinner = false;

            // showing success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Bond buy Deleted',//currentRow.FirstName + ' '+ currentRow.LastName +' Contact deleted.',
                variant: 'success'
            }),);

            this.swapU();
            // refreshing table data using refresh apex
            // return refreshApex(this.wiredResult);

        })
        .catch(error => {
            window.console.log('Error ====> '+error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!', 
                message: error.message, 
                variant: 'error'
            }),);
        });
    }




     handleRowSelection(event){
         // eslint-disable-next-line no-console
          console.log('ROW Action '+JSON.stringify(event));
          this.selectedRow.forEach(row=>{
          // eslint-disable-next-line no-console
          console.log('ROW COLUMN'+row);        })

    }

     
     handleSave(event) {
            let tempResult = {}
                //combine cell based on same Id-------->
                this.draftData.forEach(function (item) {
                    Object.keys(item).forEach(function(key) { //2
                        if (!tempResult[item.Id]) tempResult[item.Id] = {}; //3
                        tempResult[item.Id][key] = item[key]; //4
                    });
                })
                let tempArray= [];
                Object.keys(tempResult).forEach(function(key) {
                    tempArray.push(tempResult[key])
                });
            
               
               
                        // eslint-disable-next-line no-console
                      //  console.log('this.investorIdData '+this.investorIdData);
                      // eslint-disable-next-line no-console
                        console.log('tempArray[0].Id'+tempArray[0].Id);

                        // eslint-disable-next-line no-console
                        console.log('this.investorIdData.includes(tempArray[0].Id)'+this.investorIdData.includes(tempArray[0].Id));
               if(this.investorIdData.includes(tempArray[0].Id)) {
               // if(tempArray[0].Id.length !== 18) { //if bond buy Id Null

                        let el = this.template.querySelector('lightning-datatable');
                        let selected = el.getSelectedRows();
                        let Investor_Id_Data=[];
                        if(selected.length >0){

                        for(let i=0;i<selected.length;i++){

                                    this.investorId = selected[i].InvestorId;
                                    Investor_Id_Data.push(this.investorId);
                                    this.bondBuyRecord = {};
                                    if(tempArray[i].Status==='undefined'){
                                        this.bondBuyRecord.Status__c = selected[i].Status;
                                    }
                                    else{
                                        this.bondBuyRecord.Status__c = tempArray[i].Status;
                                    } 
                                    this.bondBuyRecord.Investor__c = selected[i].InvestorId;
                                    this.bondBuyRecord.Bond_Offering__c = this.bondOffId;

                                    if(tempArray[i].Units==null){                 
                                        this.bondBuyRecord.Units__c = selected[i].Units;
                                    }
                                    else{
                                        this.bondBuyRecord.Units__c = tempArray[i].Units;
                                    }
                        
                                    this.bondBuysList.push(this.bondBuyRecord);
                            }
                    }

                        createBonds({data:JSON.stringify(this.bondBuysList)}).then( test => {
                              //  BOND_ID.fieldApiName =test.Id;
                              //  tempArray[0].Id = test.Id;
                                
                        // eslint-disable-next-line no-console
                        console.log('test'+JSON.stringify(test));
                                this.bondBuysList = {};
                               // this.refresh();
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'All Bond Buy Created',
                                            variant: 'success'
                                        })
                                    );
                                // Clear all draft values
                                this.draftValues = [];
                                tempArray= [];
                                tempResult={};
                                this.swapU();  
                               // this.swapC();
                    
                             
                        }).catch(error => {
                            this.bondBuysList = [];
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: error.body.message,
                                    variant: 'error'
                                })
                            );
                    })
                }
                else{
                    const recordInputs =  event.detail.draftValues.slice().map(draft => {
                        
                         // eslint-disable-next-line no-console
                         console.log(draft);

                        let temp={
                            Id:draft.Id,
                            Units__c:draft.Units,
                            Status__c:draft.Status,
                            Investor__c:draft.Name,
                            Type__c:draft.Type ,
                            Bond_Offering__c:this.bondOffId};
                            //const fields = Object.assign({}, temp);
                            return Object.assign({}, temp);//{ fields };
                        });

                            
                        // eslint-disable-next-line no-console
                        console.log('records to update'+JSON.stringify(recordInputs));

                   // const promises = recordInputs.map(recordInput => updateRecord(recordInput));
                   // Promise.all(promises)
                    
                   updateBonds({data:JSON.stringify(recordInputs)})
                    .then( ()=> {
                        //this.refresh(); 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'All Bond Buy updated',
                                variant: 'success'
                            })
                        );
                    // Clear all draft values
                    this.draftValues = [];
                    tempArray= [];
                    tempResult={};
                    this.swapU();

                   // this.refresh();
                  // location.reload(true);

                    }).catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    })
                }
        
    }

    @api refresh() {
        return refreshApex(this.wiredResults); 
    }
}

