public with sharing class CommunalServiceUserController {
  @AuraEnabled
  public static String getUserEmail(String userId) {
    try {
      List<Communal_Service_User__c> userList = [
        SELECT Id, Email__c
        FROM Communal_Service_User__c
        WHERE User__c = :userId
      ];

      if (userList.isEmpty()) {
        throw new CustomException(
          'Communal Service User with userId: ' +
          userId +
          ' was not found'
        );
      }

      return userList[0].Email__c;
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, Boolean> userHasDebt(String userId) {
    try {
      List<Communal_Service_User__c> userList = [
        SELECT Id, User__c, Debt__c
        FROM Communal_Service_User__c
        WHERE User__c = :userId
      ];

      if (userList.isEmpty()) {
        throw new CustomException(
          'Communal Service User with userId: ' +
          userId +
          ' was not found'
        );
      }

      return new Map<String, Boolean>{ 'result' => userList[0].Debt__c > 0 };
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

  @AuraEnabled
  public static Communal_Service_User__c changeAddress(String payload) {
    try {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload
      );
      String userId = (String) payloadMap.get('userId');
      String regionId = (String) payloadMap.get('regionId');
      String cityId = (String) payloadMap.get('cityId');
      String managerId = (String) payloadMap.get('managerId');

      List<Communal_Service_User__c> userList = [
        SELECT Id, User__c, Region__c, City__c, Region_Manager__c
        FROM Communal_Service_User__c
        WHERE User__c = :userId
      ];

      if (userList.isEmpty()) {
        throw new CustomException(
          'Communal Service User with userId: ' +
          userId +
          ' was not found'
        );
      }

      Communal_Service_User__c user = userList[0];
      user.Region__c = regionId;
      user.City__c = cityId;
      user.Region_Manager__c = managerId;

      update user;
      return user;
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Communal_Service_User__c getCommunalServiceUserRegion(
    String userId
  ) {
    try {
      List<Communal_Service_User__c> usersList = [
        SELECT Id, User__c, Region__r.Name, City__r.Name
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
