import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BICYCLE_OBJECT from '@salesforce/schema/Bicycle__c';
import NAME_FIELD from '@salesforce/schema/Bicycle__c.Name';
import TYPE_FIELD from '@salesforce/schema/Bicycle__c.Type__c';
import MANUFACTURER_FIELD from '@salesforce/schema/Bicycle__c.Manufacturer__c';
import COLOR_FIELD from '@salesforce/schema/Bicycle__c.Color__c';
import LOCATION_FIELD from '@salesforce/schema/Bicycle__c.Location__c';
import OWNER_ID_FIELD from '@salesforce/schema/Bicycle__c.Owner_ID__c';
import BASE_PRICE_FIELD from '@salesforce/schema/Bicycle__c.Base_Price__c';
import PEDAL_TYPE_FIELD from '@salesforce/schema/Bicycle__c.Pedal_Type__c';
import PEDAL_MANUFACTURER_FIELD from '@salesforce/schema/Bicycle__c.Pedal_Manufacturer__c';
import PEDAL_TYPE_MANUFACTURER_FIELD from '@salesforce/schema/Bicycle__c.Pedal_Type_Manufacturer__c';
import BRAKE_TYPE_FIELD from '@salesforce/schema/Bicycle__c.Brake_Type__c';
import TIRE_TYPE_FIELD from '@salesforce/schema/Bicycle__c.Tire_Type__c';
import SUSPENSION_FIELD from '@salesforce/schema/Bicycle__c.Suspension_Configuration__c';
import HANDLEBAR_FIELD from '@salesforce/schema/Bicycle__c.Handlebar_Type__c';
import SEAT_TYPE_FIELD from '@salesforce/schema/Bicycle__c.Seat_Type__c';
import MANUFACTURED_COUNTRY_FIELD from '@salesforce/schema/Bicycle__c.Manufactured_Country__c';
import EXPEDITED_ORDER_FIELD from '@salesforce/schema/Bicycle__c.Expedited_Order__c';
import LAMINATION_FIELD from '@salesforce/schema/Bicycle__c.Lamination__c';
import PERSONAL_DECALS_FIELD from '@salesforce/schema/Bicycle__c.Personal_Decals__c';
import DECAL_DESCRIPTION_FIELD from '@salesforce/schema/Bicycle__c.Decal_Description__c';

export default class BicycleCreate extends NavigationMixin(LightningElement) {
    bicycleObject = BICYCLE_OBJECT;
    nameField = NAME_FIELD;
    typeField = TYPE_FIELD;
    manufacturerField = MANUFACTURER_FIELD;
    colorField = COLOR_FIELD;
    locationField = LOCATION_FIELD;
    ownerIdField = OWNER_ID_FIELD;
    basePriceField = BASE_PRICE_FIELD;
    pedalTypeField = PEDAL_TYPE_FIELD;
    pedalManufacturerField = PEDAL_MANUFACTURER_FIELD;
    pedalTypeManufacturerField = PEDAL_TYPE_MANUFACTURER_FIELD;
    brakeTypeField = BRAKE_TYPE_FIELD;
    tireTypeField = TIRE_TYPE_FIELD;
    suspensionField = SUSPENSION_FIELD;
    handlebarField = HANDLEBAR_FIELD;
    seatTypeField = SEAT_TYPE_FIELD;
    manufacturedCountryField = MANUFACTURED_COUNTRY_FIELD;
    expeditedOrderField = EXPEDITED_ORDER_FIELD;
    laminationField = LAMINATION_FIELD;
    personalDecalsField = PERSONAL_DECALS_FIELD;
    decalDescriptionField = DECAL_DESCRIPTION_FIELD;

    isLoading = true;
    recordTypeId;

    @wire(getObjectInfo, { objectApiName: BICYCLE_OBJECT })
    wiredObjectInfo({ data }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        }
    }

    handleLoad() {
        this.isLoading = false;
    }

    handleSubmit(event) {
        event.preventDefault();
        if (!this.validateFields()) {
            return;
        }
        this.isLoading = true;
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    }

    handleSuccess(event) {
        this.isLoading = false;
        const recordId = event.detail.id;
        const recordName = event.detail.fields.Name?.value;
        this.showToast('Bicycle created', `${recordName || 'The bicycle'} was saved.`, 'success');
        this.resetForm();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName: 'Bicycle__c',
                actionName: 'view'
            }
        });
    }

    handleError(event) {
        this.isLoading = false;
        this.showToast('Bicycle was not saved', this.errorMessage(event.detail), 'error');
    }

    handleReset() {
        this.resetForm();
    }

    validateFields() {
        return [...this.template.querySelectorAll('lightning-input-field')].reduce(
            (valid, field) => field.reportValidity() && valid,
            true
        );
    }

    resetForm() {
        this.template.querySelectorAll('lightning-input-field').forEach((field) => field.reset());
    }

    errorMessage(detail) {
        const fieldMessages = Object.values(detail?.output?.fieldErrors || {})
            .flat()
            .map((item) => item.message);
        const pageMessages = (detail?.output?.errors || []).map((item) => item.message);
        const messages = [...pageMessages, ...fieldMessages].filter(Boolean);
        return messages.length ? messages.join(' ') : detail?.message || 'Check the required fields and try again.';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}