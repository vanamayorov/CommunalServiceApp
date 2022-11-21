import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ContactManagerModal from "c/contactManagerModal";

export default class ToolbarWrapper extends LightningElement {
  handleClick() {
    ContactManagerModal.open({
      size: "medium",
      description: "Contact Manager Modal",
      content: {
        headerText: "Contact My Manager"
      }
    }).then((res) => {
      this.handleMessageSent(res);
    });
  }

  handleMessageSent(res) {
    if (res === "success") {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Letter was successfully sent",
          variant: "success"
        })
      );
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: `An error occured, leter wasn't sent
        Details: ${res?.body?.message}`,
          variant: "error"
        })
      );
    }
  }
}
