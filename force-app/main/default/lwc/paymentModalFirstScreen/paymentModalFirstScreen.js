import { LightningElement, api } from "lwc";
import getUnpaidMonthlyBills from "@salesforce/apex/CommunalServiceUserController.getUnpaidMonthlyBills";
import Id from "@salesforce/user/Id";

export default class PaymentModalFirstScreen extends LightningElement {
  @api availableActions = [];
  @api currentStep;
  @api steps;
  unpaidBills = [];
  optionsForSelect = [];
  unpaidBillValue = "";
  chosenBill = {};

  connectedCallback() {
    getUnpaidMonthlyBills({ userId: Id })
      .then((bills) => {
        this.unpaidBills = bills;
        this.optionsForSelect = bills.map((bill) => ({
          label: `${bill.Month__c} ${bill.Year__c}`,
          value: bill.Id
        }));
      })
      .catch((err) => console.error(err));
  }

  handleSelectChange(e) {
    this.unpaidBillValue = e.detail.value;
    this.chosenBill = this.unpaidBills.find(
      (bill) => bill.Id === this.unpaidBillValue
    );
  }

  get chosenBillSet() {
    return Object.keys(this.chosenBill).length > 0;
  }

  get chosenBillNotSet() {
    return !this.chosenBillSet;
  }

  handleNextStep() {
    this.dispatchEvent(
      new CustomEvent("handlenextstep", {
        detail: this.chosenBill
      })
    );
  }
}
