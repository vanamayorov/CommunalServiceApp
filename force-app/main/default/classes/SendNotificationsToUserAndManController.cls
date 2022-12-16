public with sharing class SendNotificationsToUserAndManController implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, User__c, Login__c, Debt__c, User__r.Name, City__r.City_Limit__c, Region_Manager__r.User__c, CurrencyIsoCode FROM Communal_Service_User__c'
    );
  }
  public void execute(
    Database.BatchableContext bc,
    List<Communal_Service_User__c> scope
  ) {
    CustomNotificationType notificationType = [
      SELECT Id, DeveloperName
      FROM CustomNotificationType
      WHERE DeveloperName = 'User_Debt_Notification'
    ];

    for (Communal_Service_User__c user : scope) {
      if (user.Debt__c >= user.City__r.City_Limit__c) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(user.Id);
        SendNotificationsToUserAndManController.sendNotificationToUser(
          user,
          notification
        );
        SendNotificationsToUserAndManController.sendNotificationToUserManager(
          user,
          notification
        );
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
  }

  private static void sendNotificationToUser(
    Communal_Service_User__c user,
    Messaging.CustomNotification notification
  ) {
    notification.setTitle('Exceeded City Limit Of Debt Notification');
    notification.setBody(
      'Please pay your bills as soon as possible! Max city debt limit is ' +
      user.City__r.City_Limit__c +
      ' ' +
      user.CurrencyIsoCode +
      '. Your debt is ' +
      user.Debt__c +
      ' ' +
      user.CurrencyIsoCode
    );
    notification.send(new Set<String>{ user.User__c });
  }

  private static void sendNotificationToUserManager(
    Communal_Service_User__c user,
    Messaging.CustomNotification notification
  ) {
    notification.setTitle('User Exceeded City Limit Of Debt Notification');
    notification.setBody(
      'Please pay attention! User: ' +
      ' ' +
      user.User__r.Name +
      ' has exceeded max city limit of debt! Max city debt limit is ' +
      user.City__r.City_Limit__c +
      ' ' +
      user.CurrencyIsoCode +
      '. User`s debt is ' +
      user.Debt__c +
      ' ' +
      user.CurrencyIsoCode
    );
    notification.send(new Set<String>{ user.Region_Manager__r.User__c });
  }
}
