import { LightningElement } from "lwc";

export default class LogRegWrapper extends LightningElement {
  isLoginFormVisible = true;

  handleLoginBtnClick() {
    this.isLoginFormVisible = true;
  }

  handleRegisterBtnClick() {
    this.isLoginFormVisible = false;
  }
}
