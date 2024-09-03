import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomModalForDataTable extends LightningElement {
    @api isDisplayMode = false;
    @api isEditMode = false;
    @api recordId;

    get header() {
        if (this.isDisplayMode) return 'Display Dimensions';
        else if (this.isEditMode) return 'Edit Dimensions';
        else return '';
    }

    closeModalHandler() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleSubmit(event) {
        event.preventDefault(); 
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showToast();
        this.closeModalHandler();
    }

    // handleSuccess() {
    //     this.showToast();
    //     this.closeModalHandler();
    // }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Record saved successfully',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
}
