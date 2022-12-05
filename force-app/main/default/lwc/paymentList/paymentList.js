import { LightningElement, wire } from "lwc";
import getPayments from "@salesforce/apex/PaymentController.getPayments";
import {
  subscribe,
  MessageContext,
  unsubscribe
} from "lightning/messageService";
import UPDATE_AFTER_PAYMENT_CHANNEL from "@salesforce/messageChannel/Update_After_Payment__c";
import { getFormattedTime } from "c/dateTimeHelper";
import Id from "@salesforce/user/Id";

const COLUMNS = [
  { label: "Id", fieldName: "id" },
  { label: "Month", fieldName: "month" },
  { label: "Year", fieldName: "year" },
  { label: "Amount", fieldName: "amount" },
  { label: "Date", fieldName: "date" },
  { label: "Status", fieldName: "status" }
];

export default class PaymentList extends LightningElement {
  columns = COLUMNS;
  subscription = null;
  isLoading = true;
  data = [];

  connectedCallback() {
    this.fetchPayments();
    this.subscribeToMessageChannel();
  }

  @wire(MessageContext)
  messageContext;
  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      UPDATE_AFTER_PAYMENT_CHANNEL,
      () => {
        this.fetchPayments();
      }
    );
  }

  fetchPayments() {
    getPayments({ userId: Id })
      .then((data) => {
        this.data = data.map((payment) => ({
          id: `/lightning/r/Payment__c/${payment.Id}/view`,
          month: payment.Monthly_Bill__r.Month__c,
          year: payment.Monthly_Bill__r.Year__c,
          amount: payment.Amount__c,
          isoCode: payment.CurrencyIsoCode,
          date: getFormattedTime(payment.Date__c),
          status: payment.Status__c
        }));
      })
      .catch(() => {
        this.data = [];
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
  }

  get paymentsListIsFilled() {
    return this.data.length;
  }
}
