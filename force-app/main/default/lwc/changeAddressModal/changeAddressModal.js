import LightningModal from "lightning/modal";
import { wire } from "lwc";
import {
  subscribe,
  MessageContext,
  unsubscribe
} from "lightning/messageService";
import { refreshApex } from "@salesforce/apex";
import userHasDebt from "@salesforce/apex/CommunalServiceUserController.userHasDebt";
import PaymentModal from "c/paymentModal";
import UPDATE_AFTER_PAYMENT_CHANNEL from "@salesforce/messageChannel/Update_After_Payment__c";
import Id from "@salesforce/user/Id";

export default class ChangeAddressModal extends LightningModal {
  region = null;
  userHasDebt = false;
  debtsResult = null;
  subscription = null;
  error = null;

  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  @wire(userHasDebt, { userId: Id })
  wiredUserHasDebt(value) {
    this.debtsResult = value;
    const { data, error } = value;
    if (data) {
      this.userHasDebt = data.result;
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

  handlePayBills() {
    PaymentModal.open({ size: "small" });
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
  }
}
