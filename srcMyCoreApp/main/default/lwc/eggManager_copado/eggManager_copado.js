import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValues from '@salesforce/apex/eggController_copado.getPicklistValues';
import createEggRecord   from '@salesforce/apex/eggController_copado.createEggRecord';

export default class EggManager_copado extends LightningElement {

    // ── Tracked state ────────────────────────────────────────────────────────
    @track orderName       = '';
    @track selectedEggType = '';
    @track selectedEggSize = '';
    @track deliveryDate    = '';
    @track dozensRequested = null;
    @track errorMessage    = '';
    @track isLoading       = false;
    @track isSaving        = false;

    eggTypeOptions = [];
    eggSizeOptions = [];

    // ── Wire picklist values from eggController_copado ───────────────────────
    @wire(getPicklistValues)
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.eggTypeOptions = (data.eggTypes || []).map(v => ({ label: v, value: v }));
            this.eggSizeOptions = (data.eggSizes || []).map(v => ({ label: v, value: v }));
        } else if (error) {
            this.errorMessage = 'Failed to load picklist values.';
        }
    }

    // ── Event handlers ───────────────────────────────────────────────────────
    handleOrderNameChange(event)  { this.orderName       = event.detail.value; this.clearError(); }
    handleTypeChange(event)       { this.selectedEggType = event.detail.value; this.clearError(); }
    handleSizeChange(event)       { this.selectedEggSize = event.detail.value; this.clearError(); }
    handleDeliveryDateChange(event) {
        this.deliveryDate = event.detail.value;
        this.clearError();
    }
    handleDozensRequestedChange(event) {
        const val = event.detail.value;
        this.dozensRequested = val ? parseInt(val, 10) : null;
        this.clearError();
    }

    clearError() { this.errorMessage = ''; }

    // ── Client-side validation ───────────────────────────────────────────────
    validateForm() {
        if (!this.orderName || !this.orderName.trim()) {
            this.errorMessage = 'Order Name is required.';
            return false;
        }
        if (!this.selectedEggType) {
            this.errorMessage = 'Egg Type is required.';
            return false;
        }
        if (!this.selectedEggSize) {
            this.errorMessage = 'Egg Size is required.';
            return false;
        }
        if (this.deliveryDate) {
            const delivery = new Date(this.deliveryDate);
            const today    = new Date();
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

    // ── Save ─────────────────────────────────────────────────────────────────
    async handleSave() {
        if (!this.validateForm()) return;
        this.isSaving = true;
        try {
            await createEggRecord({
                eggType:         this.selectedEggType,
                eggSize:         this.selectedEggSize,
                dateCollected:   null,
                description:     null,
                orderName:       this.orderName,
                deliveryDate:    this.deliveryDate  || null,
                dozensRequested: this.dozensRequested
            });
            this.dispatchEvent(new ShowToastEvent({
                title:   'Success',
                message: 'Egg record saved successfully.',
                variant: 'success'
            }));
            this.resetForm();
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title:   'Error saving record',
                message: error.body ? error.body.message : error.message,
                variant: 'error'
            }));
        } finally {
            this.isSaving = false;
        }
    }

    // ── Reset ────────────────────────────────────────────────────────────────
    handleReset() { this.resetForm(); }

    resetForm() {
        this.orderName       = '';
        this.selectedEggType = '';
        this.selectedEggSize = '';
        this.deliveryDate    = '';
        this.dozensRequested = null;
        this.errorMessage    = '';
    }
}