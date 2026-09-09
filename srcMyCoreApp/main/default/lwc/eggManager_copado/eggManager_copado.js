import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEggTypes from '@salesforce/apex/EggManagerController_copado.getEggTypes';
import getEggSizes from '@salesforce/apex/EggManagerController_copado.getEggSizes';
import saveEggRecord from '@salesforce/apex/EggManagerController_copado.saveEggRecord';

export default class EggManager_copado extends LightningElement {
    @track eggTypeOptions = [];
    @track eggSizeOptions = [];
    @track selectedEggType = '';
    @track selectedEggSize = '';
    @track isLoading = false;

    connectedCallback() {
        this.loadPicklistData();
    }

    loadPicklistData() {
        this.isLoading = true;
        Promise.all([getEggTypes(), getEggSizes()])
            .then(([types, sizes]) => {
                this.eggTypeOptions = types.map(t => ({ label: t, value: t }));
                this.eggSizeOptions = sizes.map(s => ({ label: s, value: s }));
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading data',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleTypeChange(event) {
        this.selectedEggType = event.detail.value;
    }

    handleSizeChange(event) {
        this.selectedEggSize = event.detail.value;
    }

    handleSave() {
        if (!this.selectedEggType || !this.selectedEggSize) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please select both an Egg Type and Egg Size.',
                    variant: 'error'
                })
            );
            return;
        }
        this.isLoading = true;
        saveEggRecord({ eggType: this.selectedEggType, eggSize: this.selectedEggSize })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Egg record saved successfully.',
                        variant: 'success'
                    })
                );
                this.resetForm();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving record',
                        message: error.body ? error.body.message : error.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleReset() {
        this.resetForm();
    }

    resetForm() {
        this.selectedEggType = '';
        this.selectedEggSize = '';
    }
}