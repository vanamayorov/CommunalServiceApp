import { api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningModal from "lightning/modal";
import getRegionManagerByUserId from "@salesforce/apex/RegionManagerController.getRegionManagerByUserId";
import contactManager from "@salesforce/apex/RegionManagerController.contactManager";
import Id from "@salesforce/user/Id";

const FORMATS = [
  "font",
  "size",
  "bold",
  "italic",
  "underline",
  "strike",
  "list",
  "indent",
  "align",
  "link",
  "clean",
  "table",
  "header",
  "color"
];

export default class ContactManagerModal extends LightningModal {
  @api content;
  contactData = {
    managerEmail: "",
    message: "",
    subject: "",
    userEmail: ""
  };
  formats = FORMATS;
  validity = true;

  connectedCallback() {
    this.fetchManagerEmail();
  }

  fetchManagerEmail() {
    getRegionManagerByUserId({ userId: Id })
      .then((res) => {
        this.contactData = {
          ...this.contactData,
          managerEmail: res.Region_Manager__r.Email__c,
          userEmail: res.Email__c
        };
      })
      .catch((err) => {
        this._showToaster(
          "Error",
          `An error occured
          Details: ${err.body.message}`,
          "error"
        );
      });
  }

  handleInputChange(event) {
    const key = event.target.dataset.id;
    this.contactData = {
      ...this.contactData,
      [key]: event.target.value
    };
    if (key === "subject") {
      this.validateInputs();
    }
    if (key === "message") {
      this.validateTextarea();
    }
  }

  validateInputs() {
    const allValid = [
      ...this.template.querySelectorAll("lightning-input")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    return allValid;
  }

  validateTextarea() {
    if (!this.contactData.message.trim()) {
      this.validity = false;
    } else {
      this.validity = true;
    }
    return this.validity;
  }

  validateAll() {
    return [this.validateInputs(), this.validateTextarea()].reduce(
      (acc, res) => acc && res,
      true
    );
  }

  sendEmail() {
    if (this.validateAll()) {
      contactManager({ payload: JSON.stringify(this.contactData) })
        .then(() => {
          this._showToaster(
            "Success",
            "Letter was successfully sent",
            "success"
          );
        })
        .catch((err) => {
          this._showToaster(
            "Error",
            `An error occured, leter wasn't sent
              Details: ${err.body.message}`,
            "error"
          );
        })
        .finally(() => this.closeModal());
    }
  }

  closeModal() {
    this.close();
  }

  _showToaster(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant
      })
    );
  }
}
