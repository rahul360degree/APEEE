import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSchoolYears from '@salesforce/apex/CloneSubscriptionsController.getSchoolYears';
import createSubscriptionHandler from '@salesforce/apex/CloneSubscriptionsController.createSubscriptionHandler';
export default class CloneSubscriptions extends LightningElement {

    fromYear = '';
    toYear = '';
    schoolYear = '';
    schoolYearOptions = [];
    subscriptionType = '';
    isError = false;
    errorMessage = '';
   @track isCancelSubscription = false;
    startDate = '';
    endDate = '';
    
    // isSameYearError = false;
    // showSubmitMessage = false;
    // isSubcriptionTypeError = false;

    get subscriptionTypes() {
        return [
            { label: 'Bus Subscription', value: 'Bus Subscription' },
            { label: 'Canteen Subscription', value: 'Canteen Subscription' }
        ];
    }

    connectedCallback(){
        getSchoolYears()
        .then(res=>{
            console.log('res ----- ' + res);
            if(res != null){
                let tempList = [];
                res.forEach(element => {
                    tempList.push({ label: element.Name , value: element.Id });
                });
                this.schoolYearOptions = tempList;
            }
            
        })
        .catch(err=>{
            console.log(err);
        })
    }

    handleYearChange(event){
        const label = event.currentTarget.dataset.label;
        const year = event.detail.value;
        console.log(JSON.stringify(event.detail)  + ' ----'+label + ' ----' + year);
        if(label == "From Year"){
            this.fromYear = year;
        }else if(label == "To Year"){
            this.toYear = year;
            let tempList = this.schoolYearOptions.filter(ele => {if(ele.value == year) return ele });
             this.schoolYear = tempList[0].label;
        }
       
    }

    handleSubscriptionChange(event){
        this.subscriptionType = event.detail.value;
        if(this.subscriptionType == 'Canteen Subscription'){
            this.isCancelSubscription = true;
        }
    }
       
    
    handleClick(){
        console.log(this.fromYear);
        console.log(this.toYear);
        console.log(this.subscriptionType);
        console.log(this.schoolYear);
        console.log(this.startDate);
        console.log(this.endDate);
        if(this.fromYear == ''){
            this.isError = true;
            this.errorMessage = 'Please Choose From Year.';
        }else if(this.toYear == ''){
            this.isError = true;
            this.errorMessage = 'Please Choose To Year';
        }else if(this.fromYear == this.toYear ){
            this.isError = true;
            this.errorMessage = 'Please Choose Different From and To Year.';
        }else if(this.subscriptionType == ''){
            this.isError = true;
            this.errorMessage = 'Please Choose Subscription Type.';
        }else if(this.fromYear != this.toYear && this.subscriptionType != ''){
            this.isError = false;
            this.errorMessage = '';
            createSubscriptionHandler({fromYear : this.fromYear , toYear : this.toYear , subscritpionType : this.subscriptionType , schoolYear : this.schoolYear,startDate: this.startDate, endDate : this.endDate})
            .then(res=>{
                this.showToast();
                
                
            })
            .catch(err=>{
                console.log(err);
                this.showToast();
            })
        }
    }

    handleDateChange(event){
        console.log('-------------'+JSON.stringify(event.detail));
        const name = event.currentTarget.dataset.label;
        const value = event.detail.value;
        if(name == 'startDate'){
            this.startDate = value;
        }else if(name == 'endDate'){
            this.endDate = value;
        }
    }

    showToast(){
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Your '+ this.subscriptionType +' has started Cloning for ' + this.schoolYear + ' , you will recieve updates on email.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.fromYear = '';
        this.toYear = '';
        this.subscriptionType = '';
        this.schoolYear = '';
        this.isCancelSubscription = false;
        this.startDate = '';
        this.endDate = '';
        }
}