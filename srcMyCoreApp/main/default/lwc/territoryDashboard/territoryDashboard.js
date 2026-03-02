import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTerritoryStatistics from '@salesforce/apex/TerritoryDashboardController_copado.getTerritoryStatistics';
import getAccountsByStatus from '@salesforce/apex/TerritoryDashboardController_copado.getAccountsByStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const TERRITORY_COLUMNS = [
    { label: 'Territory Code', fieldName: 'territoryCode', type: 'text' },
    { label: 'Manager', fieldName: 'managerName', type: 'text' },
    { label: 'Account Count', fieldName: 'accountCount', type: 'number' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Last Assignment', fieldName: 'lastAssignmentDate', type: 'date' }
];

const ACCOUNT_COLUMNS = [
    { label: 'Account Name', fieldName: 'Name', type: 'text' },
    { label: 'Territory Code', fieldName: 'Territory_Code__c', type: 'text' },
    { label: 'Manager', fieldName: 'managerName', type: 'text' },
    { label: 'Status', fieldName: 'Territory_Status__c', type: 'text' },
    { label: 'Assignment Date', fieldName: 'Territory_Assignment_Date__c', type: 'date' }
];

export default class TerritoryDashboard extends LightningElement {
    @track stats = {};
    @track selectedStatus = '';
    @track filteredAccounts = [];
    @track isLoading = true;
    wiredStatsResult;

    territoryColumns = TERRITORY_COLUMNS;
    accountColumns = ACCOUNT_COLUMNS;

    @wire(getTerritoryStatistics)
    wiredStats(result) {
        this.wiredStatsResult = result;
        this.isLoading = true;
        
        if (result.data) {
            this.stats = result.data;
            this.isLoading = false;
        } else if (result.error) {
            this.handleError(result.error);
            this.isLoading = false;
        }
    }

    get hasData() {
        return this.stats && this.stats.totalAccounts > 0;
    }

    get territories() {
        return this.stats.territories || [];
    }

    get hasFilteredAccounts() {
        return this.filteredAccounts && this.filteredAccounts.length > 0;
    }

    handleStatusClick(event) {
        const status = event.currentTarget.dataset.status;
        this.selectedStatus = status;
        this.loadAccountsByStatus(status);
    }

    loadAccountsByStatus(status) {
        this.isLoading = true;
        getAccountsByStatus({ status: status })
            .then(result => {
                this.filteredAccounts = result.map(account => ({
                    ...account,
                    managerName: account.Territory_Manager__r?.Name
                }));
                this.isLoading = false;
            })
            .catch(error => {
                this.handleError(error);
                this.isLoading = false;
            });
    }

    handleRefresh() {
        this.isLoading = true;
        this.filteredAccounts = [];
        this.selectedStatus = '';
        refreshApex(this.wiredStatsResult);
    }

    handleError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (error.body && error.body.message) {
            message = error.body.message;
        }
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading territory data',
                message: message,
                variant: 'error'
            })
        );
    }
}