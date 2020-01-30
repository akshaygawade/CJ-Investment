import { LightningElement,api,wire,track} from 'lwc';
import { refreshApex } from '@salesforce/apex';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import SOLD_FIELD from '@salesforce/schema/Bond_Offering__c.Units_Sold__c';
import REMAINING_FIELD from '@salesforce/schema/Bond_Offering__c.Units_Remaining__c';
import PENDING_FIELD from '@salesforce/schema/Bond_Offering__c.Units_Pending__c';

const fields = [SOLD_FIELD, REMAINING_FIELD, PENDING_FIELD];

export default class BondOffering_PageCenter extends LightningElement {
    
    @api recordId ;
    @track itemName;

    tempSold=0;
    tempRemain=1000;
    tempPending=0;

    @wire(getRecord, { recordId: '$recordId', fields })
    bonds;


    get UnitsSold() {
      this.tempSold = this.bonds.data ? getFieldValue(this.bonds.data, SOLD_FIELD): 0;
       // return getFieldValue(this.bondtitle.data, SOLD_FIELD);
       // eslint-disable-next-line no-console
       console.log('this.tempSold'+this.tempSold);
        return this.tempSold;
    }

    get UnitsRemaining() {
        this.tempRemain = this.bonds.data ? getFieldValue(this.bonds.data, REMAINING_FIELD): 1000;
           // eslint-disable-next-line no-console
       console.log('this.tempRemain'+this.tempRemain);
         return this.tempRemain;
    }
    get UnitsPending() {
        this.tempPending = this.bonds.data ? getFieldValue(this.bonds.data, PENDING_FIELD): 0;
           // eslint-disable-next-line no-console
       console.log('this.tempPending'+this.tempPending);
         return this.tempPending;
    }

   @api handleRefresh(){
    // eslint-disable-next-line no-console
       console.log('in refresh center');

        return refreshApex(this.bonds); 
    }
   // return refreshApex(this.recordId);

}