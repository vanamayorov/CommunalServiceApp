import LightningModal from "lightning/modal";

const STEPS = [
  { label: "Choose Monthly Bill", value: 0 },
  { label: "Enter Credentials", value: 1 },
  { label: "Payment Result", value: 2 }
];

export default class PaymentModal extends LightningModal {
  currentStep = 0;
  steps = STEPS;

  handleNextStep() {
    return this.currentStep + 1 >= this.steps.length
      ? this.currentStep
      : this.currentStep++;
  }

  handleFinish() {
    this.close();
  }

  handleGoBack() {
    this.currentStep--;
  }

  get currentStepLabel() {
    return this.steps[this.currentStep].label;
  }
}
