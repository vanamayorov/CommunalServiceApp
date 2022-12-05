import { LightningElement, api } from "lwc";

export default class PaymentModalThirdScreen extends LightningElement {
  @api paymentInfo;
  @api steps;
  @api currentStep;

  handleFinish() {
    this.dispatchEvent(new CustomEvent("handlefinish"));
  }

  tryAgain() {
    this.dispatchEvent(new CustomEvent("goback"));
  }

  get paymentSuccessfull() {
    return this.paymentInfo.status === "Success";
  }

  get paymentStatusOk() {
    return this.paymentInfo.payload.ok;
  }
}
