public with sharing class CommunalServiceUserController {
  @AuraEnabled
  public static String getUserEmail(String userId) {
    try {
      Communal_Service_User__c user = [
        SELECT Id, Email__c
        FROM Communal_Service_User__c
        WHERE User__c = :userId
        LIMIT 1
      ];

      return user.Email__c;
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, Boolean> userHasDebt(String userId) {
    try {
      Communal_Service_User__c user = [
        SELECT Id, User__c, Debt__c
        FROM Communal_Service_User__c
        WHERE User__c = :userId
        LIMIT 1
      ];

      return new Map<String, Boolean>{ 'result' => user.Debt__c > 0 };
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Monthly_Bill__c> getUnpaidMonthlyBills(String userId) {
    try {
      return [
        SELECT
          Id,
          Left_To_Pay__c,
          Year__c,
          Month__c,
          CurrencyIsoCode,
          Communal_Service_User__r.User__c
        FROM Monthly_Bill__c
        WHERE Communal_Service_User__r.User__c = :userId AND Left_To_Pay__c > 0
      ];
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  public static List<Messaging.SendEmailResult> notifyUsers(
    List<Communal_Service_User__c> communalServiceUsers
  ) {
    List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();
    EmailTemplate template = [
      SELECT Id, Name
      FROM EmailTemplate
      WHERE Name = 'Meters Readings Reminder Email'
      LIMIT 1
    ];

    for (Communal_Service_User__c user : communalServiceUsers) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setTemplateId(template.Id);
      mail.setTargetObjectId(user.User__c);
      mail.setSaveAsActivity(false);
      mail.setSenderDisplayName('Communal Payments Service');
      listOfEmails.add(mail);
    }

    List<Messaging.SendEmailResult> results = Messaging.sendEmail(listOfEmails);
    return results;
  }

  public static List<Communal_Service_User__c> getUsersWithUnfilledReadings(
    List<Communal_Service_User__c> communalServiceUsers
  ) {
    List<Communal_Service_User__c> result = new List<Communal_Service_User__c>();
    for (Communal_Service_User__c user : communalServiceUsers) {
      if (user.Meters_Readings__r.isEmpty()) {
        result.add(user);
      }
    }
    return result;
  }
}
