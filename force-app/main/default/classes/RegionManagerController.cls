public with sharing class RegionManagerController {
  @AuraEnabled
  public static Communal_Service_User__c getRegionManagerByUserId(
    String userId
  ) {
    try {
      List<Communal_Service_User__c> usersList = [
        SELECT Id, User__c, Region_Manager__r.Email__c, User__r.Email
        FROM Communal_Service_User__c
        WHERE User__c = :userId
      ];

      if (usersList.isEmpty()) {
        throw new CustomException(
          'Communal Service User with userId: ' +
          userId +
          ' was not found'
        );
      }

      return usersList[0];
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, Boolean> contactManager(String payload) {
    try {
      Boolean emailSentSuccessfully = true;
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload
      );
      String managerEmail = (String) payloadMap.get('managerEmail');
      String message = (String) payloadMap.get('message');
      String subject = (String) payloadMap.get('subject');
      String userEmail = (String) payloadMap.get('userEmail');
      List<Messaging.SendEmailResult> emailsRes = EmailService.sendEmail(
        userEmail,
        managerEmail,
        subject,
        message
      );
      for (Messaging.SendEmailResult res : emailsRes) {
        emailSentSuccessfully = emailSentSuccessfully && res.success;
      }
      return new Map<String, Boolean>{
        'sentSuccessfully' => emailSentSuccessfully
      };
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
