import { LightningElement, api, wire, track } from 'lwc';
import getGridData from '@salesforce/apex/DynamicGridController.getGridData';

export default class DynamicDataGrid extends LightningElement {
    @api objectApiName = 'Account'; 
    @api fieldsToDisplay = 'Name, Industry, Phone, Type';

    @track columns = [];
    @track allRecords = [];
    @track filteredRecords = [];
    
    filterValue = '';
    isLoading = true;

    @wire(getGridData, { sObjectName: '$objectApiName', fieldCSV: '$fieldsToDisplay' })
    wiredData({ error, data }) {
        if (data) {
            this.columns = data.columns;
            this.allRecords = data.records;
            this.filteredRecords = data.records;
            this.isLoading = false;
        } else if (error) {
            console.error('Grid Metadata Retrieval Failure:', error);
            this.isLoading = false;
        }
    }

    handleFilterChange(event) {
        this.filterValue = event.target.value.toLowerCase();
        
        if (!this.filterValue) {
            this.filteredRecords = this.allRecords;
            return;
        }

        // Senior client-side algorithmic engine: Scan every primitive data point dynamically
        this.filteredRecords = this.allRecords.filter(record => {
            return Object.keys(record).some(key => {
                return String(record[key]).toLowerCase().includes(this.filterValue);
            });
        });
    }
}
