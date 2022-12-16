import { LightningElement } from "lwc";
import login from "@salesforce/apex/LoginController.login";
import verifyUserIsAuthorized from "@salesforce/apex/LoginController.verifyUserIsAuthorized";
import Id from "@salesforce/user/Id";

export default class LoginFormScreen extends LightningElement {
  formData = {
    login: "",
    password: "",
    userId: Id
  };
  btnIsDisabled = true;
  error = null;

  handleInput(e) {
    const key = e.target.name;

    this.formData = {
      ...this.formData,
      [key]: e.target.value.trim()
    };

    this.validateInputs();
  }

  handleLoginBtnClick() {
    login({ payload: JSON.stringify(this.formData) })
      .then(() => {
        return verifyUserIsAuthorized({ userId: Id });
      })
      .then(() => {
        window.location.reload();
      })
      .catch((err) => {
        this.btnIsDisabled = true;
        this.error = err.body.message;
      });
  }

  validateInputs() {
    this.btnIsDisabled = ![
      ...this.template.querySelectorAll("lightning-input")
    ].reduce((validSoFar, inputCmp) => {
      return validSoFar && inputCmp.checkValidity();
    }, true);
  }
}
