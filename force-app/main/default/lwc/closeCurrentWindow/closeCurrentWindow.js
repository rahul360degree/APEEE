import { LightningElement } from 'lwc';

export default class CloseCurrentWindow extends LightningElement {
    connectedCallback(){
        window.close();
    }
}