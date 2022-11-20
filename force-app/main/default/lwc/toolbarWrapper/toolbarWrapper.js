import { LightningElement } from "lwc";
import ContactManagerModal from "c/contactManagerModal";

export default class ToolbarWrapper extends LightningElement {
  async handleClick() {
    await ContactManagerModal.open({
      size: "medium",
      description: "Contact Manager Modal",
      content: {
        headerText: "Contact My Manager"
      }
    });
  }
}
