import { LightningElement, api ,track,wire } from 'lwc';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//import { NavigationMixin } from 'lightning/navigation';
import TITLE from '@salesforce/schema/Bond_Offering__c.Name';

const fields =[TITLE];

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BondOffering_PageHeader extends LightningElement {
    
    @api recordId ;
    temp='';
    @wire(getRecord, { recordId: '$recordId', fields })
    bondtitle;

    get title(){
        this.temp = this.bondtitle.data ? getFieldValue(this.bondtitle.data, TITLE):'New Bond Offering';
       // return getFieldValue(this.bondtitle.data, TITLE);
        return this.temp;
    }
    
    @track accountId;
    @track bondOfferingRecord={};
    @track error;
    @track itemName=0;

    handleSuccess (event){
        
        this.recordId = event.detail.id;
        const evt = new ShowToastEvent({
            title: "Success!",
            message: "The Bond Offering record has been successfully saved.",
            variant: "success",
        });
        this.dispatchEvent(evt);
        //this.dispatchEvent(new CustomEvent('recordChange'));
    }
        
    handleTableData(){  
                        // eslint-disable-next-line no-console
                        console.log('refresh in pb');
                        this.template.querySelector('c-bond-offering_-page-center').handleRefresh();
                        // eslint-disable-next-line no-console
                        console.log('refresh in pb2');
                       // this.dispatchEvent(new CustomEvent('recordChange'));
                        this.itemName++;
        }
    navigateToEdit(){
                        // eslint-disable-next-line no-console
                        console.log('navigate To Edit');
                              //    this.navigateF();
          const value = this.recordId;                       
            this.dispatchEvent(new CustomEvent('navigateto',{ detail: { value }}));
         
                        // eslint-disable-next-line no-console
                        console.log('navigate To value '+value);   
        }
      /*        
    navigateF() {
        
        // eslint-disable-next-line no-console
        console.log('this.bondOffId in navigate'+this.recordId);  
      
      this[NavigationMixin.Navigate]({
          type: 'lightning__RecordPage',
          attributes: {
              recordId: this.recordId,
              objectApiName: 'Bond_Offering__c',
              actionName: 'edit'
          }
          
      });
     
      
        // eslint-disable-next-line no-console
     //   console.log('this.bondOffId in navigate'+this.bondOffId);  
  } */
      
}