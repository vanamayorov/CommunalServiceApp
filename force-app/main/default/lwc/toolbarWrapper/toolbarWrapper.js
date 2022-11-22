import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ContactManagerModal from "c/contactManagerModal";
import PaymentModal from "c/paymentModal";
import userHasDebt from "@salesforce/apex/CommunalServiceUserController.userHasDebt";
import Id from "@salesforce/user/Id";

export default class ToolbarWrapper extends LightningElement {
  SUCCESS_MODAL_CLOSE = "success";
  FAILED_MODAL_CLOSE = "failed";
  userHasDebt = false;

  @wire(userHasDebt, { userId: Id })
  wiredUserHasDebt(value) {
    const { data, error } = value;
    if (data) {
      this.userHasDebt = !data.result;
    }
    if (error) {
      console.log(error);
    }
  }

  openContactManagerModal() {
    ContactManagerModal.open({
      size: "medium",
      description: "Contact Manager Modal"
    }).then((res) => {
      if (res) this.handleMessageSent(res);
    });
  }

  openPaymentModal() {
    PaymentModal.open({
      size: "small",
      content: {
        headerText: "Make Payments"
      }
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
