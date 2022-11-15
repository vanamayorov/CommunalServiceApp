import { LightningElement } from "lwc";
import getPayments from "@salesforce/apex/PaymentController.getPayments";
import Id from "@salesforce/user/Id";

export default class PaymentList extends LightningElement {
  columns = [
    { label: "Link", fieldName: "link" },
    { label: "Month", fieldName: "month" },
    { label: "Year", fieldName: "year" },
    { label: "Amount", fieldName: "amount" },
    { label: "Status", fieldName: "status" }
  ];
  data = [];

  connectedCallback() {
    this.fetchPayments();
  }

  fetchPayments() {
    getPayments({ userId: Id }).then((res) => {
      this.data = res.map((payment) => ({
        link: `/lightning/r/Payment__c/${payment.Id}/view`,
        month: payment.Monthly_Bill__r.Month__c,
        year: payment.Monthly_Bill__r.Year__c,
        amount: payment.Amount__c,
        status: payment.Status__c
      }));
    });
  }
}
