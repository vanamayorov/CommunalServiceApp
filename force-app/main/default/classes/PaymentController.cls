public with sharing class PaymentController {
  @AuraEnabled
  public static List<Payment__c> getPayments(String userId) {
    try {
      return [
        SELECT
          Id,
          Amount__c,
          Monthly_Bill__r.Year__c,
          Monthly_Bill__r.Month__c,
          Date__c,
          Status__c,
          CurrencyIsoCode
        FROM Payment__c
        WHERE Monthly_Bill__r.Communal_Service_User__r.User__c = :userId
        ORDER BY Date__c DESC
      ];
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Response payForMonth(String payload) {
    try {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload
      );
      String cardNumber = (String) payloadMap.get('cardNumber');
      String cvv = (String) payloadMap.get('cvv');
      String expiration = (String) payloadMap.get('expiration');
      String owner = (String) payloadMap.get('owner');
      Double amount = Double.valueOf((String) payloadMap.get('amount'));
      String billId = (String) payloadMap.get('billId');
      String email = (String) payloadMap.get('email');
      PaymentServiceResponse paymentServiceResp = PaymentService.paymentSucceded(
        cardNumber,
        cvv,
        expiration,
        owner,
        amount
      );

      Payment__c payment = new Payment__c(
        Monthly_Bill__c = billId,
        Amount__c = amount,
        Date__c = Datetime.now(),
        Status__c = paymentServiceResp.success
          ? 'Successfully paid'
          : 'Failed to pay'
      );

      insert payment;

      PaymentPDFController.generatePDF(payment.Id, email);

      return new Response(
        paymentServiceResp.success,
        payment,
        paymentServiceResp.errorMessage
      );
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  public class Response {
    @AuraEnabled
    public Boolean ok;
    @AuraEnabled
    public Payment__c payload;
    @AuraEnabled
    public String errorMsg;

    public Response(Boolean isOk, Payment__c payload, String errorMsg) {
      this.ok = isOk;
      this.payload = payload;
      this.errorMsg = errorMsg;
    }
  }
}
