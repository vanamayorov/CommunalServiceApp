import { api } from "lwc";
import LightningModal from "lightning/modal";
import getUnpaidMonthlyBills from "@salesforce/apex/CommunalServiceUserController.getUnpaidMonthlyBills";
import Id from "@salesforce/user/Id";

export default class PaymentModal extends LightningModal {
  @api content;
  currentStep = 1;
  steps = [
    { label: "Choose Monthly Bill", value: 1 },
    { label: "Enter Credentials", value: 2 }
  ];

  connectedCallback() {
    this.fetchUnpaidBills();
  }

  fetchUnpaidBills() {
    getUnpaidMonthlyBills({ userId: Id })
      .then((res) => console.log(res))
      .catch((err) => console.error(err));
  }

  handleNextStep() {
    return this.currentStep + 1 > this.steps.length
      ? this.currentStep
      : this.currentStep++;
  }

  handlePrevStep() {
    if (this.currentStep - 1 < 0) {
      this.currentStep = 0;
    } else {
      this.currentStep--;
    }
  }
}
