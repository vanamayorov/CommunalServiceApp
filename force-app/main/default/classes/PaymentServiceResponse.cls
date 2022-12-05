public with sharing class PaymentServiceResponse {
  public Boolean success { get; set; }
  public String errorMessage { get; set; }

  public PaymentServiceResponse(Boolean success, String errorMessage) {
    this.success = success;
    this.errorMessage = errorMessage;
  }
}
