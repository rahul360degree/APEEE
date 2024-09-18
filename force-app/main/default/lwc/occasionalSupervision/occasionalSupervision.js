import { LightningElement,track } from 'lwc';
import getHouseholdStudent from '@salesforce/apex/OccasionalSupervisionController.getHouseholdStudent';
import getPlannedActivity from '@salesforce/apex/OccasionalSupervisionController.getPlannedActivity';
import occSupervisionSubmit from '@salesforce/apex/OccasionalSupervisionController.occSupervisionSubmit';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OccasionalSupervision extends LightningElement {
    loggedInUserId = userId ;
    showNextModal = false;
    showHiddenSection = false;
    @track selectedValue;
    @track selectedDate;
    @track dateError;
    showModal = false;
    studentList    = [];
    occName = '';
    contactId = '';
    className = '';
    classID = '';
    startDate = '';
    endDate = '';
    schoolYear = '';
    activityName = '';
    dayofWeek = '';
    selectedValuePA = '';
    plannedAVList = [];
    @track dayOfWeek = '';
    @track startTime = '';
    @track endTime = '';
    @track startTimeToShow = '';
    @track endTimeToShow = '';
    @track conId;
    @track parent;
    
    get codeOptions(){
        if(!this.selectedDate){
            return [];
        } 
        let dt = new Date(this.selectedDate);
        let day = dt.getDay();
        let weekObj = {
            0 : 'Sunday',
            1 : 'Monday',
            2 : 'Tuesday',
            3 : 'Wednesday',
            4 : 'Thursday',
            5 : 'Friday',
            6 : 'Saturday'
        };
        console.log('this.plannedAVList::'+JSON.stringify(this.plannedAVList));
        let options = this.plannedAVList.filter(ele =>{
           return ele.Day__c === weekObj[day];
        });
        let temp = [];
        options.forEach(element =>{
            let className = this.className ? this.className.slice(0,2) : '';
            if(element.Class__c.includes(className)){
                temp.push({
                    label : element.Code__c,
                    value : element.Id
                })
            }
        });
        return temp;
        
    }
    connectedCallback(){
       getHouseholdStudent({recordId : this.loggedInUserId}).then(res => {
        if(res && res.status === 'success'){
            this.studentList = res.accConList;
            this.parent = res.userContactId;
        } else{
            console.log('Error :: '+res.errorMessage);
        }
     })
    }
    handleClick(){
        this.showModal = true;
    }
    handleCancel(){
        this.showModal = false;
    }
    
    handleBack(){
        this.showNextModal = false;
        this.showModal = true;
    }
    handleClose(){
        this.showNextModal = false;
        this.showHiddenSection = false;
    }
    handleRadioChange(event) {
        this.occName = event.target.value;
        this.contactId = event.target.dataset.id;
        console.log('this.contactId----'+this.contactId);
        getPlannedActivity({recordId : this.contactId}).then(res => {
            console.log('res:::='+JSON.stringify(res));
            if(res && res.status === 'success'){
                console.log('res.plannedActivityList---'+JSON.stringify(res.plannedActivityList));
                this.plannedAVList = res.plannedActivityList;
                this.className = res.className;
                this.classID = res.classId;
            } else{
                console.log('Error :: '+res.errorMessage);
            }
         })
    }
    handleNext(){
            this.studentList.forEach(element =>{
                if(element.Id === this.contactId){
                    this.conId = element.ContactId;
                }
            })
            this.showNextModal = true;
            this.showModal = false;
    }
    handleDateChange(event) {
        this.selectedDate = event.target.value;
        const selectedDate = new Date(this.selectedDate);
        console.log('selectedDate:::'+selectedDate);
        const today = new Date();
        if (selectedDate <= today) {
            this.dateError = 'Please select a date greater than today.';
        } else {
            this.dateError = null;
        }
    }
    handleSelectionChange(event) {
        this.selectedValuePA = event.detail.value;
        this.plannedAVList.forEach(element => {
            let elem = {...element}
            if(this.selectedValuePA === elem.Id){
                this.dayOfWeek = elem.Day__c;
                this.startTime = elem.Start_Time__c;
                this.endTime = elem.End_Time__c;
                this.schoolYear = elem.School_Year__c;
                this.startDate = elem.Start_Date__c;
                this.endDate = elem.End_Date__c;
                this.activityName = elem.Activity_Name_EN__c;
                this.dayofWeek = elem.Day__c;
                this.showHiddenSection =true;
            }
        });
        
            const timeInMilliseconds = this.startTime;
            const date = new Date(timeInMilliseconds);
            const hours = date.getUTCHours();
            const minutes = date.getUTCMinutes();
            this.startTimeToShow = hours + ':' + minutes;
        
            const milliseconds = this.endTime;
            const enddate = new Date(milliseconds);
            const endhours = enddate.getUTCHours();
            const endminutes = enddate.getUTCMinutes();
            this.endTimeToShow = endhours + ':' + endminutes;
        return hiddenData;
    }
    handleSubmit(){
        occSupervisionSubmit({occName : this.occName, occDate : this.selectedDate, occPlannedActivity : this.selectedValuePA,occClass : this.classID, scholYear : this.schoolYear, startDate : this.startDate, endDate : this.endDate, startTime : this.startTime, endTime : this.endTime, activityName : this.activityName, dayofWeek : this.dayofWeek, conId : this.conId, parentId : this.parent}).then(res=>{
            if(res && res.status === 'success'){
                this.ShowToast('Success', 'Occasional Supervision created Successfully!', 'success', 'dismissable');
                this.showNextModal = false;
                this.showHiddenSection = false;
            }
        })
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