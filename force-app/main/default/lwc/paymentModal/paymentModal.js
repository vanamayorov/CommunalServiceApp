import { wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import LightningModal from "lightning/modal";
import UPDATE_AFTER_PAYMENT_CHANNEL from "@salesforce/messageChannel/Update_After_Payment__c";

const STEPS = [
  { label: "Choose Monthly Bill", value: 0 },
  { label: "Enter Credentials", value: 1 },
  { label: "Payment Result", value: 2 }
];

export default class PaymentModal extends LightningModal {
  currentStep = 0;
  steps = STEPS;

  @wire(MessageContext)
  messageContext;

  handleNextStep() {
    return this.currentStep + 1 >= this.steps.length
      ? this.currentStep
      : this.currentStep++;
  }

  handleFinish() {
    publish(this.messageContext, UPDATE_AFTER_PAYMENT_CHANNEL, {
      status: "updated"
    });
    this.close();
  }

  handleGoBack() {
    this.currentStep--;
  }

  get currentStepLabel() {
    return this.steps[this.currentStep].label;
  }
}
