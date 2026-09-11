import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValues from '@salesforce/apex/eggController_copado.getPicklistValues';
import createEggRecord from '@salesforce/apex/eggController_copado.createEggRecord';

export default class EggEntryForm_copado extends LightningElement {
    @track eggType = '';
    @track eggSize = '';
    @track dateCollected = '';
    @track description = '';
    @track orderName = '';
    @track deliveryDate = '';
    @track dozensRequested = null;
    @track errorMessage = '';
    @track isSaving = false;

    eggTypeOptions = [];
    eggSizeOptions = [];

    @wire(getPicklistValues)
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.eggTypeOptions = (data.eggTypes || []).map(v => ({ label: v, value: v }));
            this.eggSizeOptions = (data.eggSizes || []).map(v => ({ label: v, value: v }));
        } else if (error) {
            this.errorMessage = 'Failed to load picklist values.';
        }
    }

    handleOrderNameChange(event)      { this.orderName       = event.detail.value; this.clearError(); }
    handleEggTypeChange(event)        { this.eggType         = event.detail.value; this.clearError(); }
    handleEggSizeChange(event)        { this.eggSize         = event.detail.value; this.clearError(); }
    handleDateChange(event)           { this.dateCollected   = event.detail.value; this.clearError(); }
    handleDescriptionChange(event)    { this.description     = event.detail.value; this.clearError(); }
    handleDeliveryDateChange(event)   { this.deliveryDate    = event.detail.value; this.clearError(); }
    handleDozensRequestedChange(event) {
        const val = event.detail.value;
        this.dozensRequested = val ? parseInt(val, 10) : null;
        this.clearError();
    }

    clearError() { this.errorMessage = ''; }

    validateForm() {
        if (!this.orderName || !this.orderName.trim()) {
            this.errorMessage = 'Order Name is required.';
            return false;
        }
        if (!this.eggType) {
            this.errorMessage = 'Egg Type is required.';
            return false;
        }
        if (!this.eggSize) {
            this.errorMessage = 'Egg Size is required.';
            return false;
        }
        if (this.dateCollected) {
            const collected = new Date(this.dateCollected);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            if (collected > today) {
                this.errorMessage = 'Date Collected cannot be in the future.';
                return false;
            }
        }
        if (this.deliveryDate) {
            const delivery = new Date(this.deliveryDate);
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            if (delivery < today) {
                this.errorMessage = 'Delivery Date cannot be in the past.';
                return false;
            }
        }
        if (this.dozensRequested !== null && this.dozensRequested <= 0) {
            this.errorMessage = 'Dozens Requested must be greater than zero.';
            return false;
        }
        return true;
    }

    async handleSave() {
        if (!this.validateForm()) return;
        this.isSaving = true;
        try {
            await createEggRecord({
                eggType:          this.eggType,
                eggSize:          this.eggSize,
                dateCollected:    this.dateCollected || null,
                description:      this.description  || null,
                orderName:        this.orderName,
                deliveryDate:     this.deliveryDate  || null,
                dozensRequested:  this.dozensRequested
            });
            this.dispatchEvent(new ShowToastEvent({
                title:   'Success',
                message: 'Egg record created successfully.',
                variant: 'success'
            }));
            this.resetForm();
        } catch (error) {
            this.errorMessage = (error && error.body && error.body.message)
                ? error.body.message
                : 'An unexpected error occurred.';
        } finally {
            this.isSaving = false;
        }
    }

    handleReset() { this.resetForm(); }

    resetForm() {
        this.eggType         = '';
        this.eggSize         = '';
        this.dateCollected   = '';
        this.description     = '';
        this.orderName       = '';
        this.deliveryDate    = '';
        this.dozensRequested = null;
        this.clearError();
    }
}