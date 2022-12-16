import { LightningElement, wire } from "lwc";
import getRegions from "@salesforce/apex/RegionController.getRegions";
import register from "@salesforce/apex/RegistrationController.register";
import Id from "@salesforce/user/Id";

export default class RegisterForm extends LightningElement {
  regionsData = [];
  regionsOptions = [];
  cities = [];
  regionId = "";
  cityId = "";
  formData = {
    login: "",
    password: "",
    regionId: "",
    cityId: "",
    managerId: "",
    userId: Id
  };
  registerBtnIsDisabled = true;
  error = null;

  @wire(getRegions)
  wiredRegions({ data, error }) {
    if (data) {
      this.regionsData = data;
      this.regionsOptions = this.regionsData.map((reg) => ({
        label: reg.Name,
        value: reg.Id
      }));
    }
    if (error) {
      this.error = error;
    }
  }

  handleChangeRegion(e) {
    this.formData = {
      ...this.formData,
      regionId: e.target.value,
      cityId: ""
    };
    this.error = null;

    const region = this.regionsData.find(
      (reg) => reg.Id === this.formData.regionId
    );
    if (region?.Region_Managers__r) {
      this.formData = {
        ...this.formData,
        managerId: region.Region_Managers__r[0].Id
      };
    } else {
      this.error = new Error(
        "This region has no manager, please select another one."
      );
    }

    this.cities =
      this.regionsData
        .find((regions) => regions.Id === this.formData.regionId)
        ?.Cities__r.map((city) => ({
          label: city.Name,
          value: city.Id
        })) ?? [];

    this.validateInputs();
  }

  handleChangeCity(e) {
    this.formData = {
      ...this.formData,
      cityId: e.target.value
    };
    this.validateInputs();
  }

  handleInput(e) {
    const key = e.target.name;

    this.formData = {
      ...this.formData,
      [key]: e.target.value.trim()
    };

    this.validateInputs();
  }

  validateInputs() {
    this.registerBtnIsDisabled = ![
      ...this.template.querySelectorAll("lightning-input, lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      return validSoFar && inputCmp.checkValidity();
    }, true);
  }

  handleRegisterBtnClick() {
    register({ payload: JSON.stringify(this.formData) })
      .then(() => {
        window.location.reload();
      })
      .catch((err) => {
        this.error = err;
      });
  }
}
