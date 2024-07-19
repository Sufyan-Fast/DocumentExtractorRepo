import { LightningElement, api, wire } from "lwc";
//import { CurrentPageReference } from 'lightning/navigation';    
import getRecord from "@salesforce/apex/GetCurrentRecord.getRecord";

export default class StickyLWCHeader extends LightningElement {
    @api recordId;
    stickyMargin;
    SFretention = {};
    //isVisible = false;

    //@wire(CurrentPageReference)
    //currentPageReference;

    @wire(getRecord, { recordId: "$recordId" })
    getRecordCallback(response) {
        const { error, data } = response;
        if (data) {
            console.log(data);
           //console.log(this.currentPageReference);
           
            let SFretention = {
                ContactName: data.ContactId__r.Name,
                Speciality: data.Specialty__c
            };

            this.SFretention = SFretention;
         }
    }

    

    renderedCallback() {
        try {
            window.onscroll = () => {
                let stickysection = this.template.querySelector(".myStickyHeader");
                let sticky2 = stickysection.offsetTop;
                console.log('sticky2=>', sticky2);
                console.log('window.pageYOffset=>',window.pageYOffset);            
                if (window.pageYOffset > sticky2) {
                    // this.isVisible = true;
                    stickysection.classList.add("slds-is-fixed");
                    this.stickyMargin = "margin-top:168px;";
                } else {
                    stickysection.classList.remove("slds-is-fixed");
                    // this.isVisible = false;
                    this.stickyMargin = "";
                }
            };
        } catch (error) {
            console.log("error =>", error);
        }
    }
}