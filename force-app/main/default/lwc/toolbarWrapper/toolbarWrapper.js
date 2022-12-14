import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  publish,
  subscribe,
  MessageContext,
  unsubscribe
} from "lightning/messageService";
import {
  subscribe as subscribeEmp,
  unsubscribe as unsubscribeEmp
} from "lightning/empApi";
import { refreshApex } from "@salesforce/apex";
import ContactManagerModal from "c/contactManagerModal";
import ChangeAddressModal from "c/changeAddressModal";
import PaymentModal from "c/paymentModal";
import userHasDebt from "@salesforce/apex/CommunalServiceUserController.userHasDebt";
import UPDATE_AFTER_PAYMENT_CHANNEL from "@salesforce/messageChannel/Update_After_Payment__c";
import Id from "@salesforce/user/Id";

export default class ToolbarWrapper extends LightningElement {
  SUCCESS_MODAL_CLOSE = "success";
  FAILED_MODAL_CLOSE = "failed";
  userHasDebt = true;
  debtsResult = null;
  error = null;
  subscription = null;
  subscriptionEmp = null;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.subscribeToFillingMetersReadingsChannel();
  }

  @wire(userHasDebt, { userId: Id })
  wiredUserHasDebt(value) {
    this.debtsResult = value;
    const { data, error } = value;
    if (data) {
      this.userHasDebt = !data.result;
    }
    if (error) {
      this.error = error;
    }
  }

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      UPDATE_AFTER_PAYMENT_CHANNEL,
      () => {
        refreshApex(this.debtsResult);
      }
    );
  }

  subscribeToFillingMetersReadingsChannel() {
    const channelName = "/event/Update_After_Filling_MetersReadings__e";
    subscribeEmp(channelName, -1, () => refreshApex(this.debtsResult)).then(
      (res) => {
        this.subscriptionEmp = res;
      }
    );
  }

  openContactManagerModal() {
    ContactManagerModal.open({
      size: "small",
      description: "Contact Manager Modal"
    }).then((res) => {
      if (res) this.handleMessageSent(res);
    });
  }

  openChangeAddressModal() {
    ChangeAddressModal.open({
      size: "small"
    });
  }

  openPaymentModal() {
    PaymentModal.open({
      size: "small"
    }).then(() => {
      publish(this.messageContext, UPDATE_AFTER_PAYMENT_CHANNEL, {
        status: "updated"
      });
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
          message: `An error occured, letter wasn't sent.
        Details: ${error?.body?.message}`,
          variant: "error"
        })
      );
    }
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    unsubscribeEmp(this.subscriptionEmp);
  }
}
