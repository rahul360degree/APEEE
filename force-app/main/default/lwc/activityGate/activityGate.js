import { LightningElement,track,wire } from 'lwc';
import getActivityCheck from '@salesforce/apex/ActivityGateController.getActivityCheck';
import getContactDetails from '@salesforce/apex/ActivityGateController.getContactDetails';
import checkOutStudents from '@salesforce/apex/ActivityGateController.checkOutStudents';
import updateColorStatus from '@salesforce/apex/ActivityGateController.updateColorStatus';
import sendNotificationToMonitors from '@salesforce/apex/ActivityGateController.sendNotificationToMonitors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import GREEN_DOT from '@salesforce/resourceUrl/green_dot';
import RED_DOT from '@salesforce/resourceUrl/red_dot'; 

const columns = [
    // { label: 'Profile Pic', fieldName: 'ImageUrl__c',type : 'customImage'},
    { label: 'Status', fieldName: 'dotImage',type : 'customImage'},
    { label: 'Student Name', fieldName: 'Student_Name__c'},
    { label: 'Class', fieldName: 'StudentClass__c'},
    { label: 'Authorized', fieldName: 'Authorized__c'},
    { type: "button", label: 'Notify', initialWidth: 100, typeAttributes: {
        label: 'Notify',
        name: 'Notify',
        title: 'View',
        disabled: false,
        value: 'view',
        iconPosition: 'left',
        iconName:'utility:notification',
        variant:'Brand'
    }
},
    // { label: 'Check In Time', fieldName: 'CheckInTime__c'},
    // { label: 'Status', fieldName: 'Status__c'},
    // { label: 'Parent', fieldName: 'ParentName__c'},
    { type: "button", label: 'View', initialWidth: 100, typeAttributes: {
            label: 'View',
            name: 'View',
            title: 'View',
            disabled: false,
            value: 'view',
            iconPosition: 'left',
            iconName:'utility:preview',
            variant:'Brand'
        }
    },
    { label: 'Status/Checkin', fieldName: 'Status__c'},
    { label: 'Checkin Time', fieldName: 'CheckInTime__c'},
    
];
const detailsColumns = [
    { label: 'Contact Name', fieldName: 'Contact_Name_Txt__c',type : 'text'},
    { label: 'Mobile', fieldName: 'Mobile__c',type : 'text'},
    { label: 'Relation', fieldName: 'Relation__c',type : 'Picklist'}
]
export default class ActivityGate extends LightningElement {
    @track columns = columns;
    @track detailsColumns = detailsColumns;
    data = [];
    @track preSelectedRows = [];
    @track searchString;
    isShowModal = false;
    activityCheckID = '';
    parentName = '';
    @track selectedRows = [];
    @track studentData = [];

    // get studentData(){
    //     if(this.wiredStudent?.data?.activityCheckList){
    //         console.log('-------'+JSON.stringify(this.wiredStudent.data.activityCheckList));
    //         let tempdata = []
    //         this.wiredStudent.data.activityCheckList.forEach(ele => {
    //             let elem = {...ele}
    //             elem.dotImage = RED_DOT
    //             tempdata.push(elem);
    //         });
    //         return tempdata;
    //     }
    //     return [];
    // }
    get studentListToShow(){
        if(this.searchString && this.searchString != ''){
            let str = this.searchString.toLowerCase();
            console.log('str--'+str);
            let tempStudentData = this.studentData.filter(ele => {
                return (ele.Student_Name__c.toLowerCase().includes(str));
            });
            console.log('tempStudentData:::'+tempStudentData);
            return tempStudentData;
        } 
        return this.studentData;
    }

    @wire(getActivityCheck)
    wiredStudent({error, data}) {
        if(data?.activityCheckList) {
            let tempdata = [];
            data?.activityCheckList.forEach(ele => {
                let elem = {...ele}
                if(elem.CheckColorStatus__c){
                    elem.dotImage = GREEN_DOT;
                    tempdata.push(elem);
                } else{
                    elem.dotImage = RED_DOT
                    tempdata.push(elem);
                }
            });
            this.studentData = tempdata;
        }
    }

    handleSearch(event){
        this.searchString = event.target.value;
    }

    callRowAction(event) {
        this.activityCheckID = event.detail.row.Id;
        console.log('this.activityCheckID:::'+this.activityCheckID);
        this.parentName = event.detail.row.ParentName__c;
        let actionName = event.detail.action.name;
        if(actionName === 'View'){
            getContactDetails({recordId : this.activityCheckID}).then(res => {
                if(res && res.status === 'success'){
                    this.isShowModal = true;
                    this.data = res.AccConDetails;
                } else{
                    console.log('Error :: '+res.errorMessage);
                }
             })
        }
        if(actionName === 'Notify'){
            let temp = [];
            this.studentData.forEach(ele => {
                console.log('ele:::'+JSON.stringify(ele));
                if(ele.Id === this.activityCheckID && ele.CheckColorStatus__c == false) {
                    ele.dotImage = GREEN_DOT;
                }
                temp.push(ele);
            });
            this.studentData = temp;
            event.detail.row.dotImage = GREEN_DOT;
            updateColorStatus({recordId : this.activityCheckID}).then(result =>{
            });
            sendNotificationToMonitors({parentName : this.parentName}).then(res =>{
                if(res && res.status === 'success'){
                    this.ShowToast('Success', 'Notificaton Sent Successfully!', 'success', 'dismissable');
                }
            })
        }
    }
    getSelected(event){
        const selectedRows = event.detail.dataset.index;
        console.log('selectedRows:::'+selectedRows);
    }
    submitDetails(event){
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('OUTPUT : ',JSON.stringify(selectedRecords));
        if(selectedRecords.length === 0){
            this.isShowModal = false;
        }else{
        checkOutStudents({selectedRecords : selectedRecords, activityCheckId : this.activityCheckID}).then(res => {
                    if(res && res.status === 'success'){
                        this.ShowToast('Success', 'Student Check Out Successfully!', 'success', 'dismissable');
                        this.isShowModal = false;
                        refreshApex(this.studentData);
                    } else{
                        console.log('Error :: '+res.errorMessage);
                    }
                })
        }
        
    }
    closeModal(){
        this.isShowModal = false;
    }
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
    }
}