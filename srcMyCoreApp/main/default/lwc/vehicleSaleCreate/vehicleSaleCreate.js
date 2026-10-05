import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getSoldCount from '@salesforce/apex/VehicleSaleController.getSoldCount';
import createSale from '@salesforce/apex/VehicleSaleController.createSale';

const BODY_STYLES = ['Sedan', 'Coupe', 'Hatchback', 'Wagon', 'SUV', 'Truck', 'Van', 'Convertible'];
const FUEL_TYPES = ['Gasoline', 'Diesel', 'Hybrid', 'Plug-in Hybrid', 'Electric'];
const TRANSMISSIONS = ['Automatic', 'Manual'];
const DRIVETRAINS = ['FWD', 'RWD', 'AWD', '4WD'];

export default class VehicleSaleCreate extends NavigationMixin(LightningElement) {
    vin = '';
    make = '';
    model = '';
    modelYear;
    trim = '';
    exteriorColor = '';
    interiorColor = '';
    mileage;
    bodyStyle = '';
    fuelType = '';
    transmission = '';
    drivetrain = '';
    salePrice;
    saleDate = new Date().toISOString().slice(0, 10);
    buyerName = '';
    isSaving = false;
    soldCount = 0;
    createdSale;

    wiredCount;

    bodyStyleOptions = BODY_STYLES.map((value) => ({ label: value, value }));
    fuelTypeOptions = FUEL_TYPES.map((value) => ({ label: value, value }));
    transmissionOptions = TRANSMISSIONS.map((value) => ({ label: value, value }));
    drivetrainOptions = DRIVETRAINS.map((value) => ({ label: value, value }));

    @wire(getSoldCount)
    wiredSoldCount(result) {
        this.wiredCount = result;
        if (result.data !== undefined) {
            this.soldCount = result.data;
        }
    }

    get soldCountLabel() {
        return this.soldCount === 1 ? '1 vehicle sold' : `${this.soldCount} vehicles sold`;
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.detail.value;
    }

    async handleSubmit(event) {
        event.preventDefault();
        if (!this.reportValidity()) {
            return;
        }

        this.isSaving = true;
        try {
            const result = await createSale({ request: this.buildRequest() });
            this.soldCount = result.soldCount;
            this.createdSale = result;
            this.resetForm();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Vehicle sale recorded',
                    message: `${result.vehicleSummary} was saved as ${result.saleNumber}.`,
                    variant: 'success'
                })
            );
            await refreshApex(this.wiredCount);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Vehicle sale was not saved',
                    message: this.errorMessage(error),
                    variant: 'error'
                })
            );
        } finally {
            this.isSaving = false;
        }
    }

    handleReset() {
        this.resetForm();
        this.createdSale = undefined;
    }

    handleViewSale() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.createdSale.recordId,
                objectApiName: 'Vehicle_Sale__c',
                actionName: 'view'
            }
        });
    }

    buildRequest() {
        return {
            vin: this.vin,
            make: this.make,
            model: this.model,
            modelYear: this.toNumber(this.modelYear),
            trim: this.trim,
            exteriorColor: this.exteriorColor,
            interiorColor: this.interiorColor,
            mileage: this.toNumber(this.mileage),
            bodyStyle: this.bodyStyle,
            fuelType: this.fuelType,
            transmission: this.transmission,
            drivetrain: this.drivetrain,
            salePrice: this.toNumber(this.salePrice),
            saleDate: this.saleDate,
            buyerName: this.buyerName,
            status: 'Sold'
        };
    }

    toNumber(value) {
        if (value === '' || value === null || value === undefined) {
            return null;
        }
        return Number(value);
    }

    reportValidity() {
        return [...this.template.querySelectorAll('lightning-input, lightning-combobox')].reduce(
            (valid, field) => field.reportValidity() && valid,
            true
        );
    }

    resetForm() {
        this.vin = '';
        this.make = '';
        this.model = '';
        this.modelYear = null;
        this.trim = '';
        this.exteriorColor = '';
        this.interiorColor = '';
        this.mileage = null;
        this.bodyStyle = '';
        this.fuelType = '';
        this.transmission = '';
        this.drivetrain = '';
        this.salePrice = null;
        this.saleDate = new Date().toISOString().slice(0, 10);
        this.buyerName = '';
    }

    errorMessage(error) {
        return error?.body?.message || 'Check the vehicle specs and try again.';
    }
}