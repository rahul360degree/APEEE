import { LightningElement, api, track, wire } from 'lwc';
import fetchData from '@salesforce/apex/RelatedListController.fetchData';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
 
// const columns = [
//     {
//         label: 'Contact Name',
//         fieldName: 'ContactId', //lookup API field name 
//         type: 'lookupColumn',
//         typeAttributes: {
//             object: 'Contact', //object name which have lookup field
//             fieldName: 'ContactId',  //lookup API field name 
//             value: { fieldName: 'ContactId' },  //lookup API field name 
//             context: { fieldName: 'Id' }, 
//             name: 'Contact',  //lookup object API Name 
//             fields: ['Contact.Name'], //lookup objectAPIName.Name
//             target: '_self'
//         },
//         editable: false,
//     },
//     {
//         label: 'Household Name',
//         fieldName: 'AccountId',
//         type: 'lookupColumn',
//         typeAttributes: {
//             object: 'Account',
//             fieldName: 'AccountId',
//             value: { fieldName: 'AccountId' },
//             context: { fieldName: 'Id' }, 
//             name: 'Account',
//             fields: ['Account.Name'],
//             target: '_self'
//         },
//         editable: false,
//     },
//     { label: 'Relation', fieldName: 'Relation__c', editable: false },
//     { label: 'Is allowed to pick up child', fieldName: 'Is_allowed_to_pick_up_child__c', type: 'checkbox', editable: false }
// ]
export default class RelatedList extends NavigationMixin(LightningElement) {

    @api parentId;
    @api fieldsData;
    @api title;
    @api objectApiName;
    @api lookupFieldApiName;
    @api filters;


    get titleDS(){
        return this.title + ' (' + this.listOfRecords + ')';
    }

    get columns() {
        return JSON.parse(this.fieldsData)
    }

    get fieldApiNames() {
        let fieldsData = JSON.parse(this.fieldsData);

        let tempFieldArr = [];
        fieldsData.forEach(ele => {
            if(ele.fieldName) tempFieldArr.push(ele.fieldName);
        })

        return tempFieldArr.join(', ');
    }
    showSpinner = false;
    @track data = [];
    @track isdataExist = false;
    @track listOfRecords = 0;
    @track objData;
    @track draftValues = [];
    lastSavedData = [];

    connectedCallback() {
        fetchData({fieldNames : this.fieldApiNames, objectApiName: this.objectApiName, parentId: this.parentId, lookupFieldApiName: this.lookupFieldApiName,filters: this.filters}).then(res => {
            
            this.data = JSON.parse(JSON.stringify(res));
            if(this.data.length > 0 ){
                this.isdataExist = true;
                this.listOfRecords = this.data.length;
            }else{
                this.isdataExist = false;
                this.listOfRecords = 0;
            }
            console.log(JSON.stringify(res));
            this.lastSavedData = JSON.parse(JSON.stringify(this.data));
        }).catch(err => {
            console.log(err);
            this.data = undefined;
        })
    }
 
    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    lookupChanged(event) {
        console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let accountIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, AccountId: accountIdVal  };
        console.log(updatedItem);
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
 
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        });
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
 
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
 
    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.accountData);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log(JSON.stringify(row));
        if(actionName === 'view') {
            this.navigateToViewPage(row.Id);
        }
    }

    navigateToViewPage(recordId) {
        console.log('123');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            },
        });
    }
}