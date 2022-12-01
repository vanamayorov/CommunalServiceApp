import { LightningElement, api } from "lwc";
import payForMonth from "@salesforce/apex/PaymentController.payForMonth";
import getUserEmail from "@salesforce/apex/CommunalServiceUserController.getUserEmail";
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
  cardNumber = "";
  expiration = "";

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
      this.formatCardNumber(e.detail.value);
      this.credentialsInfo.cardNumber = this.cardNumber.split(" ").join("");
    }

    if (key === "expiration") {
      this.formatExpireDate(e.detail.value);
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

  formatCardNumber(value) {
    const matches = value
      .replace(/\s+/g, "")
      .replace(/[^0-9]/gi, "")
      .match(/\d{4,16}/g);
    const match = (matches && matches[0]) || "";
    const parts = [];
    for (let i = 0; i < match.length; i += 4) {
      parts.push(match.substring(i, i + 4));
    }

    if (parts.length) {
      this.cardNumber = parts.join(" ");
    } else {
      this.cardNumber = value;
    }
  }

  formatExpireDate(value) {
    this.expiration = value
      .replace(/[^0-9]/g, "")
      .replace(/^([2-9])$/g, "0$1")
      .replace(/^(1{1})([3-9]{1})$/g, "0$1/$2")
      .replace(/^0{1,}/g, "0")
      .replace(/^([0-1]{1}[0-9]{1})([0-9]{1,2}).*/g, "$1/$2");
  }

  get nextBtnDisabled() {
    return !Object.values(this.formState).reduce((acc, val) => {
      return acc && val;
    }, true);
  }
}
