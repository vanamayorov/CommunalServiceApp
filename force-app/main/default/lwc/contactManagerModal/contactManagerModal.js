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
  "header"
];

export default class ContactManagerModal extends LightningModal {
  contactData = {
    managerEmail: "",
    message: "",
    subject: "",
    userEmail: ""
  };
  formats = FORMATS;
  validity = true;

  connectedCallback() {
    getRegionManagerByUserId({ userId: Id })
      .then((res) => {
        this.contactData = {
          ...this.contactData,
          managerEmail: res.Region_Manager__r.Email__c,
          userEmail: res.Email__c
        };
      })
      .catch((err) => this.closeModal(err));
  }

  handleInputChange(event) {
    const key = event.target.dataset.id;
    this.contactData = {
      ...this.contactData,
      [key]: event.target.value
    };
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
        .then(() => this.closeModal({ status: "success" }))
        .catch((err) => this.closeModal({ status: "failed", error: err }));
    }
  }

  closeModal(res) {
    this.close(res);
  }
}
