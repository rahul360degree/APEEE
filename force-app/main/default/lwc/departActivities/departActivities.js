import { LightningElement,track,wire } from 'lwc';
import getActivityCheck from '@salesforce/apex/DepartActivityController.getActivityCheck';
import GREEN_DOT from '@salesforce/resourceUrl/green_dot';
import RED_DOT from '@salesforce/resourceUrl/red_dot'; 
const columns = [
    { label: 'Profile Pic', fieldName: 'ImageUrl__c',type : 'customImage'},
    { label: 'Status', fieldName: 'dotImage',type : 'customImage'},
    { label: 'Student Name', fieldName: 'Student_Name__c'},
    { label: 'Class', fieldName: 'StudentClass__c'},
    { label: 'GPS Group', fieldName: 'GPS_Groupe__c'},
    { label: 'Check In Time', fieldName: 'CheckInTime__c'},
    
];
export default class DepartActivities extends LightningElement {
    @track columns = columns;
    data = [];
    @track searchString;
    @track studentData = [];
    get studentListToShow(){
        if(this.searchString && this.searchString != ''){
            let str = this.searchString;
            console.log('this.studentData--'+JSON.stringify(this.studentData));
            console.log('str--::'+str);
            let tempStudentData = this.studentData.filter(ele => {
                return (ele.Student_Name__c.toLowerCase().includes(str) || ele.Student_Name__c.toUpperCase().includes(str));
            })
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
}