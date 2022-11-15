public with sharing class PaymentController {
  @AuraEnabled(Cacheable=true)
  public static List<Payment__c> getPayments(String userId) {
    try {
      return [
        SELECT
          Id,
          Amount__c,
          Status__c,
          Monthly_Bill__r.Year__c,
          Monthly_Bill__r.Month__c
        FROM Payment__c
        WHERE Monthly_Bill__r.Communal_Service_User__r.User__c = :userId
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
