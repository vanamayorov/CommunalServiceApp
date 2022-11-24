public with sharing class CommunalServiceUserController {
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
