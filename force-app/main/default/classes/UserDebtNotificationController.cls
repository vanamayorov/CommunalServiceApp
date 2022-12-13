public with sharing class UserDebtNotificationController implements Schedulable {
  public void execute(SchedulableContext ctx) {
    CustomNotificationType notificationType = [
      SELECT Id, DeveloperName
      FROM CustomNotificationType
      WHERE DeveloperName = 'User_Debt_Notification'
    ];

    for (Communal_Service_User__c user : [
      SELECT
        Id,
        User__c,
        Debt__c,
        User__r.Name,
        City__r.City_Limit__c,
        Region_Manager__r.User__c,
        CurrencyIsoCode
      FROM Communal_Service_User__c
    ]) {
      if (user.Debt__c >= user.City__r.City_Limit__c) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(user.Id);
        UserDebtNotificationController.sendNotificationToUser(
          user,
          notification
        );
        UserDebtNotificationController.sendNotificationToUserManager(
          user,
          notification
        );
      }
    }
  }

  private static Messaging.CustomNotification sendNotificationToUser(
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
    return notification;
  }

  private static Messaging.CustomNotification sendNotificationToUserManager(
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
    return notification;
  }
}
