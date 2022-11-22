public with sharing class RegionManagerController {
  @AuraEnabled(cacheable=true)
  public static Communal_Service_User__c getRegionManagerByUserId(
    String userId
  ) {
    try {
      return [
        SELECT Id, User__c, Region_Manager__r.Email__c, Email__c
        FROM Communal_Service_User__c
        WHERE User__c = :userId
        LIMIT 1
      ];
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void contactManager(String payload) {
    try {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload
      );
      String managerEmail = (String) payloadMap.get('managerEmail');
      String message = (String) payloadMap.get('message');
      String subject = (String) payloadMap.get('subject');
      String userEmail = (String) payloadMap.get('userEmail');
      EmailService.sendEmail(userEmail, managerEmail, subject, message);
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
