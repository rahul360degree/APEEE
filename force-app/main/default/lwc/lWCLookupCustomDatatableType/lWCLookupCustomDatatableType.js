import LightningDatatable from 'lightning/datatable';
import lookupColumn from './lookupColumn.html';

export default class LWCLookupCustomDatatableType extends LightningDatatable  {
    static customTypes = {
        lookupColumn: {
            template: lookupColumn,
            standardCellLayout: true,
            typeAttributes: ['value', 'fieldName', 'object', 'context', 'name', 'fields', 'target']
        }
    };
}