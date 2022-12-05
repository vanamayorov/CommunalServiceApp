import { LightningElement, api } from "lwc";

export default class PaymentModalBodyWrapper extends LightningElement {
  @api step;
  @api steps;
  chosenBill = null;
  paymentInfo = {};

  get firstStepScreen() {
    return this.step === 0;
  }

  get secondStepScreen() {
    return this.step === 1;
  }

  get thirdStepScreen() {
    return this.step === 2;
  }

  handleFirstStep(e) {
    this.chosenBill = e.detail;
    this.dispatchEvent(new CustomEvent("handlenextstep"));
  }

  handleSecondStep(e) {
    this.paymentInfo = e.detail;
    this.dispatchEvent(new CustomEvent("handlenextstep"));
  }

  handleGoBack() {
    this.dispatchEvent(new CustomEvent("goback"));
  }

  handleFinish() {
    this.dispatchEvent(new CustomEvent("handlefinish"));
  }
}
