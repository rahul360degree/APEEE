import { LightningElement,api ,track,wire} from 'lwc';
import jsPDF from '@salesforce/resourceUrl/jsPDF';
import { loadScript } from 'lightning/platformResourceLoader';
import getActivityCheck from '@salesforce/apex/ActivityPrintViewController.getActivityCheck';

export default class ActivityPrintViewByStudent extends LightningElement {
    dataList = [];
    jsPdfInitialized=false;
    connectedCallback(){
        getActivityCheck({}).then(res => {
           console.log('res::::'+JSON.stringify(res));
        }).catch(err => {
            console.log(err);
            this.data = undefined;
        })
    }
    renderedCallback(){
        loadScript(this, jsPDF ).then(() => {});
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;
    }
    generatePdf(){
        const { jsPDF } = window.jspdf;
         const doc = new jsPDF();

    }
    @track name;
  @track accountName;
  @track email;
  @track billTo;
  @track shipTo;
  @track phone;
  @api recordId;
  
    
    generateData(){
        this.generatePdf();
}
}