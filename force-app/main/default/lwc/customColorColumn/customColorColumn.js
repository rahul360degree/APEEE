import LightningDatatable from 'lightning/datatable';
import customStatus from './customStatusColor.html';

export default class CustomDataTable extends LightningDatatabl {
    static customTypes = {
        customStatus : {
            template : customStatus,
            typeAttributes : ['title']
        }
    }
}