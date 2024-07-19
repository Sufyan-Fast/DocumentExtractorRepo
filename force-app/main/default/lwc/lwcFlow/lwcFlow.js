// saveFlowDataButton.js
import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class SaveFlowDataButton extends LightningElement {
    @api
    availableActions = [];
    recordId='0038J00000E8hraQAB'
    
    saveFlowData() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId, // Replace with the actual record Id
                actionName: 'view'
            }
        });
    }
    saveAndRedirect() {
        // Trigger the flow navigation to the next screen
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}