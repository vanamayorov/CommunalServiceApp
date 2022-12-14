import LightningModal from "lightning/modal";
import PaymentModal from "c/paymentModal";
import { wire } from "lwc";
import {
  subscribe,
  MessageContext,
  unsubscribe
} from "lightning/messageService";
import { refreshApex } from "@salesforce/apex";
import userHasDebt from "@salesforce/apex/CommunalServiceUserController.userHasDebt";
import getRegions from "@salesforce/apex/RegionController.getRegions";
import changeAddress from "@salesforce/apex/CommunalServiceUserController.changeAddress";
import getCommunalServiceUserRegion from "@salesforce/apex/CommunalServiceUserController.getCommunalServiceUserRegion";
import UPDATE_AFTER_PAYMENT_CHANNEL from "@salesforce/messageChannel/Update_After_Payment__c";
import Id from "@salesforce/user/Id";

export default class ChangeAddressModal extends LightningModal {
  regionsData = [];
  regionsOptions = [];
  cities = [];
  regionId = "";
  cityId = "";
  managerId = "";
  currentRegion = "";
  currentCity = "";
  successfullyChangedAdress = false;
  userHasDebt = false;
  debtsResult = null;
  subscription = null;
  error = null;

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.fetchCurrentAddress();
  }

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

  @wire(userHasDebt, { userId: Id })
  wiredUserHasDebt(value) {
    this.debtsResult = value;
    const { data, error } = value;
    if (data) {
      this.userHasDebt = data.result;
    }
    if (error) {
      this.error = error;
    }
  }

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannel() {
    this.subscription = subscribe(
      this.messageContext,
      UPDATE_AFTER_PAYMENT_CHANNEL,
      () => {
        refreshApex(this.debtsResult);
      }
    );
  }

  fetchCurrentAddress() {
    getCommunalServiceUserRegion({ userId: Id })
      .then((res) => {
        this.currentRegion = res.Region__r.Name;
        this.currentCity = res.City__r.Name;
      })
      .catch((err) => {
        this.error = err;
      });
  }

  handleChangeRegion(e) {
    this.regionId = e.target.value;
    this.cityId = "";
    this.error = null;

    const region = this.regionsData.find((reg) => reg.Id === this.regionId);
    if (region?.Region_Managers__r) {
      this.managerId = region.Region_Managers__r[0].Id;
    } else {
      this.error = new Error(
        "This region has no manager, please select another one."
      );
    }

    this.cities =
      this.regionsData
        .find((regions) => regions.Id === this.regionId)
        ?.Cities__r?.filter((city) => city.Name !== this.currentCity)
        .map((city) => ({
          label: city.Name,
          value: city.Id
        })) ?? [];
  }

  handleChangeCity(e) {
    this.cityId = e.target.value;
  }

  handleChangeAddress() {
    const payload = {
      regionId: this.regionId,
      cityId: this.cityId,
      userId: Id,
      managerId: this.managerId
    };

    changeAddress({ payload: JSON.stringify(payload) })
      .then(() => {
        this.successfullyChangedAdress = true;
      })
      .catch((err) => {
        this.error = err;
      });
  }

  handlePayBills() {
    PaymentModal.open({ size: "small" });
  }

  handleClose() {
    this.close();
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
  }

  get changeAddressBtnDisabled() {
    return !(this.regionId && this.cityId && !this.error);
  }
}
