import { LightningElement, api, track, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi"; // Fetch Picklist Values from Server DB
import state from "@salesforce/schema/CME__c.State_s__c";
import { CurrentPageReference } from "lightning/navigation";
import saveRecord from "@salesforce/apex/cmeCreaterController.saveContact";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const MAX_FILE_SIZE = 100000000; // 10mb

export default class CMECreater extends NavigationMixin(LightningElement) {
  // Picklist values for Category
  CategoryValues = [
    { label: "AMA Category 1", value: "AMA Category 1" },
    { label: "AMA Category 2", value: "AMA Category 2" },
    { label: "AOA Category 1", value: "AOA Category 1" },
    { label: "AOA Category 2", value: "AOA Category 2" },
    { label: "N/A", value: "N/A" },
  ];

  // Picklist values for Subject
  SubjectValues = [
    { label: "Child Abuse", value: "Child Abuse" },
    { label: "Depression/Suicide", value: "Depression/Suicide" },
    { label: "General", value: "General" },
    { label: "HIPAA", value: "HIPAA" },
    { label: "Human Trafficking", value: "Human Trafficking" },
    { label: "Infection Prevention", value: "Infection Prevention" },
    { label: "NIHSS", value: "NIHSS" },
    { label: "Stroke", value: "Stroke" },
    { label: "Other", value: "Other" },
  ];

  // Getting States PickList values frin SF object field
  @wire(getPicklistValues, {
    recordTypeId: "012TH0000001MjF",
    fieldApiName: state,
  })
  picklistResults({ error, data }) {
    if (data) {
      this.stateValues = data.values;
      console.log("stateValues", this.stateValues);
    } else if (error) {
      var errordata = error;
      console.log("errordata", errordata);
    }
  }
//fetch page reference to get url Parmeters values
  @wire(CurrentPageReference) pageRef;

  @api recordId;
  @api recordIds;
  @track name;
  @track administeredBy;
  @track credit;
  @track conName;
  @track Completetion;
  @track Expiration;
  @track Category;
  @track Subject;
  @track stateValues;
  @track contactId;
  @track stateValue;
  chkBoxCompletion = false;
  saveFlag = true;
  nameFile;
  uploadedFiles = [];
  file;
  fileContents;
  fileReader;
  content;
  fileName;

  // Event handler for name input change
  onNameChange(event) {
    this.name = event.detail.value;
  }

  // Event handler for administered by input change
  onAdministeredChange(event) {
    this.administeredBy = event.detail.value;
  }

  // Event handler for credit input change
  onCreditChange(event) {
    this.credit = event.detail.value;
  }
  // Event handler for categary   change
  handleAMAChange(eve) {
    this.Category = eve.detail.value;
    console.log("Category", this.Category);
  }

  // Event handler for checkbox change
  handlechkBoxChange(event) {
    this.chkBoxCompletion = !this.chkBoxCompletion;
    console.log("this.chkBoxCompletion ", this.chkBoxCompletion);
  }

  // Event handler for completion date input change
  onCompletetionChange(event) {
    this.Completetion = event.detail.value;
    console.log("this.Completetion", this.Completetion);
  }

  // Event handler for expiration date input change
  onExpirationChange(event) {
    this.Expiration = event.detail.value;
    console.log("this.Expiration", this.Expiration);
  }

  // Event handler for subject dropdown change
  onSubjectChange(event) {
    this.Subject = event.detail.value;
    console.log("this.Subject", this.Subject);
  }

  // Event handler for state dropdown change
  handleStateChange(event) {
    this.stateValue = event.detail.value;
    console.log("this.stateValue", this.stateValue);
  }

  // Event handler for file upload
  onFileUpload(event) {
    if (event.target.files.length > 0) {
      this.uploadedFiles = event.target.files;
      console.log("event.target.files", event.target.files);
      console.log("this.uploadedFiles", this.uploadedFiles);
      this.fileName = event.target.files[0].name;
      this.file = this.uploadedFiles[0];
      if (this.file.size > this.MAX_FILE_SIZE) {
        alert("File Size Can not exceed" + MAX_FILE_SIZE);
      }
    }
  }

  // Connected callback lifecycle hook
  connectedCallback() {
    //fetching the Contact id parameter from URL 
    if (this.pageRef) {
      const state = this.pageRef.state;
      const fragment = state.fragment;

      if (fragment) {
        const urlParams = new URLSearchParams(fragment);
        const conId = urlParams.get("conId");
        console.log("conId from URL fragment:", conId);
        this.contactId = conId;
        this.recordId = conId;
      }
    }
  }

  // Event handler for saving contact
  saveContact() {
    if (this.name == "" || this.uploadedFiles.length == 0 || this.file == "") {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error ",
          variant: "error ",
          message: "Please Must Enter Name And Upload File Attachment!",
        })
      );
    } else {
      this.fileReader = new FileReader();
      this.fileReader.onloadend = () => {
        this.fileContents = this.fileReader.result;
        let base64 = "base64,";
        this.content = this.fileContents.indexOf(base64) + base64.length;
        this.fileContents = this.fileContents.substring(this.content);
        this.saveRecord();
      };
      this.fileReader.readAsDataURL(this.file);
    }
  }

  // Event handler for saving record
  saveRecord() {
    var con1 = {
      sobjectType: "CME__c",
      Name: this.name,
      Administered_By__c: this.administeredBy,
      Credit_Hours__c: this.credit,
      Completetion_Date__c: this.Completetion,
      Expiration_Date__c: this.Expiration,
      AMA_AOA_Category__c: this.Category,
      Subject__c: this.Subject,
      Provider__c: this.contactId,
      State_s__c: this.stateValue,
      Pending_Completion__c: this.chkBoxCompletion,
    };
    console.log("con1", con1);
    saveRecord({
      cmeRec: con1,
      file: encodeURIComponent(this.fileContents),
      fileName: this.fileName,
    })
      .then((cmeRecId) => {
        if (cmeRecId) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              variant: "success",
              message: "CME Record  Successfully created",
            })
          );
          if (this.saveFlag) {
            this[NavigationMixin.Navigate]({
              type: "standard__recordPage",
              attributes: {
                recordId: cmeRecId,
                objectApiName: "CME__c",
                actionName: "view",
              },
            });
          }
          this.clearForm();
        }
      })
      .catch((error) => {
        console.log("error ", error);
      });
  }

  // Event handler for saving new contact
  saveNewContact(eve) {
    this.saveFlag = false;
    this.saveContact();
  }

  // Event handler for contact lookup change
  handleContactLookupChange(event) {
    console.log("Selected Contact Id:", event.detail.value[0]);
    this.contactId = event.detail.value[0];
    console.log("contactId:", this.contactId);
  }

  // Event handler for cancel button
  handleCancel() {
    //on cancel navigate to Previous Page
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: "Contact",
        actionName: "view",
      },
    });
  }

  // Clear the form
  clearForm() {
    this.name = "";
    this.administeredBy = "";
    this.credit = "";
    this.Completetion = "";
    this.Expiration = "";
    this.Category = "";
    this.Subject = "";
    this.stateValue = "";
    this.fileName = "";
    this.uploadedFiles = [];
    this.saveFlag = true;
    this.file = "";
    this.chkBoxCompletion = false;
  }
}