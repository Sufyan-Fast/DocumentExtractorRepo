import { LightningElement, wire } from 'lwc';
import ShowListOfAccount from '@salesforce/apex/Datatable.ShowListOfHotels';
import ShowFilterredList from '@salesforce/apex/Datatable.ShowFilterredList';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Rating', fieldName: 'Rating', type: 'text' },
];

export default class DataTable extends LightningElement {
    searchTerm = '';
    data = [];
    columns = columns;

    @wire(ShowListOfAccount)
    wiredAccounts(result) {
        if (result.data) {
            this.data = result.data;
        } else if (result.error) {
            console.error('Error loading account data', result.error);
            this.data = undefined;
        }
    }

    handleInputChange(event) {
        this.searchTerm = event.target.value;
        console.log(this.searchTerm);
       
		if( searchTerm.length > 3 ){

			ShowFilterredList({ result: this.searchTerm })
            .then(result => {
                this.data = result;
            })
            .catch(error => {
                console.error('Error loading filtered list', error);
                this.data = undefined;
            });

		}
        
    }
}