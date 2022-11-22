import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ContactManagerModal from "c/contactManagerModal";

export default class ToolbarWrapper extends LightningElement {
  SUCCESS_MODAL_CLOSE = "success";
  FAILED_MODAL_CLOSE = "failed";
  handleClick() {
    ContactManagerModal.open({
      size: "medium",
      description: "Contact Manager Modal"
    }).then((res) => {
      if (res) this.handleMessageSent(res);
    });
  }

  handleMessageSent({ status, error }) {
    if (status === this.SUCCESS_MODAL_CLOSE) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Letter was successfully sent",
          variant: "success"
        })
      );
    }
    if (status === this.FAILED_MODAL_CLOSE) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: `An error occured, leter wasn't sent
        Details: ${error?.body?.message}`,
          variant: "error"
        })
      );
    }
  }
}
