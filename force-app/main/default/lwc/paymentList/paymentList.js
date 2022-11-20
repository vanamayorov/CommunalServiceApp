import { LightningElement, wire } from "lwc";
import getPayments from "@salesforce/apex/PaymentController.getPayments";
import Id from "@salesforce/user/Id";

export default class PaymentList extends LightningElement {
  columns = [
    { label: "Id", fieldName: "id" },
    { label: "Month", fieldName: "month" },
    { label: "Year", fieldName: "year" },
    { label: "Amount", fieldName: "amount" },
    { label: "Status", fieldName: "status" }
  ];
  isLoading = true;
  data = [];

  @wire(getPayments, { userId: Id })
  wiredPayments({ data, error }) {
    if (error) {
      this.data = [];
      this.isLoading = false;
    }

    if (data) {
      this.data = data.map((payment) => ({
        id: `/lightning/r/Payment__c/${payment.Id}/view`,
        month: payment.Monthly_Bill__r.Month__c,
        year: payment.Monthly_Bill__r.Year__c,
        amount: payment.Amount__c,
        status: payment.Status__c,
        isSuccess: payment.Status__c === "Successfully paid"
      }));
      this.isLoading = false;
    }
  }

  get paymentsListIsFilled() {
    return this.data.length;
  }
}
