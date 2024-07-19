import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";

export default class QuickEditFormExample extends LightningElement {
  @api recordId;
  @api objectApiName;

  handleSuccess(e) {
    // Close the modal window and display a success toast
    this.dispatchEvent(new CloseActionScreenEvent());
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: "Record updated!",
        variant: "success",
      }),
    );
  }
}