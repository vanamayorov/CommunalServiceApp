import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import payForMonth from "@salesforce/apex/PaymentController.payForMonth";
import getUserEmail from "@salesforce/apex/CommunalServiceUserController.getUserEmail";
import paymentLib from "@salesforce/resourceUrl/paymentlib";
import Id from "@salesforce/user/Id";

export default class PaymentModalSecondScreen extends LightningElement {
  @api bill;
  @api steps;
  @api currentStep;
  credentialsInfo = {
    cardNumber: "",
    cvv: "",
    owner: "",
    expiration: "",
    amount: 0
  };
  formState = {
    cardNumber: false,
    cvv: false,
    owner: false,
    expiration: false,
    amount: false
  };

  connectedCallback() {
    Promise.all([loadScript(this, paymentLib)]);
  }

  handleInput(e) {
    const key = e.target.name;

    this.credentialsInfo = {
      ...this.credentialsInfo,
      [key]: e.target.value
    };

    this.formState = {
      ...this.formState,
      [key]: e.target.checkValidity()
    };

    if (key === "cardNumber") {
      // eslint-disable-next-line no-undef
      Payment.formatCardNumber(e.target);
      this.credentialsInfo.cardNumber = this.credentialsInfo.cardNumber
        .split(" ")
        .join("");
    }

    if (key === "expiration") {
      // eslint-disable-next-line no-undef
      Payment.formatCardExpiry(e.target);
      this.credentialsInfo.expiration = this.credentialsInfo.expiration
        .split(" ")
        .join("");
    }
  }

  handleNextStep() {
    getUserEmail({ userId: Id })
      .then((email) =>
        payForMonth({
          payload: JSON.stringify({
            ...this.credentialsInfo,
            billId: this.bill.Id,
            email
          })
        })
      )
      .then((res) =>
        this.dispatchEvent(
          new CustomEvent("handlenextstep", {
            detail: {
              payload: res,
              status: "Success"
            }
          })
        )
      )
      .catch((err) => {
        this.dispatchEvent(
          new CustomEvent("handlenextstep", {
            detail: {
              payload: err,
              status: "Error"
            }
          })
        );
      });
  }

  get nextBtnDisabled() {
    return !Object.values(this.formState).reduce((acc, val) => {
      return acc && val;
    }, true);
  }
}
