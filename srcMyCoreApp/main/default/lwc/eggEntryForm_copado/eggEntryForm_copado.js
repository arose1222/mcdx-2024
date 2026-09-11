import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValues from '@salesforce/apex/eggController_copado.getPicklistValues';
import createEggRecord from '@salesforce/apex/eggController_copado.createEggRecord';

export default class EggEntryForm_copado extends LightningElement {
    @track eggType = '';
    @track eggSize = '';
    @track dateCollected = '';
    @track description = '';
    @track eggTypeOptions = [];
    @track eggSizeOptions = [];
    @track errorMessage = '';
    @track isSaving = false;

    connectedCallback() {
        this.loadPicklistValues();
    }

    loadPicklistValues() {
        getPicklistValues()
            .then(result => {
                this.eggTypeOptions = result.eggTypes.map(val => ({ label: val, value: val }));
                this.eggSizeOptions = result.eggSizes.map(val => ({ label: val, value: val }));
            })
            .catch(error => {
                console.error('eggEntryForm_copado - loadPicklistValues error:', JSON.stringify(error));
                this.showToast('Error', 'Unable to load picklist values. Please refresh the page.', 'error');
            });
    }

    handleEggTypeChange(event) { this.eggType = event.detail.value; this.clearError(); }
    handleEggSizeChange(event) { this.eggSize = event.detail.value; this.clearError(); }
    handleDateChange(event) { this.dateCollected = event.detail.value; this.clearError(); }
    handleDescriptionChange(event) { this.description = event.detail.value; }

    handleSave() {
        if (!this.validateForm()) { return; }
        this.isSaving = true;
        this.clearError();
        createEggRecord({
            eggType: this.eggType,
            eggSize: this.eggSize,
            dateCollected: this.dateCollected || null,
            description: this.description || null
        })
        .then(() => {
            this.showToast('Success', 'Egg record created successfully!', 'success');
            this.resetForm();
        })
        .catch(error => {
            const msg = error && error.body && error.body.message ? error.body.message : 'An unexpected error occurred.';
            this.errorMessage = msg;
            console.error('eggEntryForm_copado - handleSave error:', JSON.stringify(error));
        })
        .finally(() => { this.isSaving = false; });
    }

    handleReset() { this.resetForm(); }

    validateForm() {
        this.clearError();
        if (!this.eggType) { this.errorMessage = 'Egg Type is required.'; return false; }
        if (!this.eggSize) { this.errorMessage = 'Egg Size is required.'; return false; }
        if (this.dateCollected) {
            const today = new Date(); today.setHours(0,0,0,0);
            if (new Date(this.dateCollected) > today) {
                this.errorMessage = 'Date Collected cannot be in the future.'; return false;
            }
        }
        return true;
    }

    resetForm() {
        this.eggType = ''; this.eggSize = ''; this.dateCollected = ''; this.description = ''; this.clearError();
    }

    clearError() { this.errorMessage = ''; }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}