import { LightningElement, track, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {
@api recordId;

    @track value ;//= 'inProgress'; //instead of hardcode here I need to use received value from parent component

    get options() {
        return [
            { label: 'New', value: 'New' },
            { label: 'Pending', value: 'Pending' },
            { label: 'Purchased', value: 'Purchased' },
            { label: 'Passed', value: 'Passed' }
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('innerpicklist', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { name: 'some data', value: this.value }
            }
        }));

    }
}