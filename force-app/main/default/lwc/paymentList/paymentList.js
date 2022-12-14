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
  { label: "Bill's Month", fieldName: "month" },
  { label: "Bill's Year", fieldName: "year" },
  { label: "Amount", fieldName: "amount" },
  { label: "Date", fieldName: "date" },
  { label: "Status", fieldName: "status" }
];

export default class PaymentList extends LightningElement {
  columns = COLUMNS;
  subscription = null;
  isLoading = true;
  data = [];
  currentPage = 0;
  numOfDisplay = 10;
  maxPages = 0;

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
          id: payment.Id,
          link: `/lightning/r/Payment__c/${payment.Id}/view`,
          month: payment.Monthly_Bill__r.Month__c,
          year: payment.Monthly_Bill__r.Year__c,
          amount: payment.Amount__c,
          isoCode: payment.CurrencyIsoCode,
          date: getFormattedTime(payment.Date__c),
          status: payment.Status__c
        }));
        this.maxPages = Math.ceil(this.data.length / this.numOfDisplay);
      })
      .catch(() => {
        this.data = [];
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleNextPage() {
    this.currentPage++;
  }

  handlePrevPage() {
    this.currentPage--;
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
  }

  get getPaymentsByPage() {
    return this.data.slice(
      this.currentPage * this.numOfDisplay,
      this.currentPage * this.numOfDisplay + this.numOfDisplay
    );
  }

  get isNextPageFinal() {
    return this.currentPage + 1 >= this.maxPages;
  }

  get isPrevPageZero() {
    return this.currentPage - 1 < 0;
  }

  get paymentsListIsFilled() {
    return this.data.length;
  }
}
