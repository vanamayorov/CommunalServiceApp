public with sharing class MetersReadingsNotificationController implements Schedulable {
  public void execute(SchedulableContext ctx) {
    String year = DateUtility.getYear();
    String month = DateUtility.getMonth();

    List<Communal_Service_User__c> communalServiceUsers = [
      SELECT
        Id,
        User__c,
        User__r.FirstName,
        User__r.LastName,
        User__r.Email,
        (
          SELECT Id, Month__c, Year__c
          FROM Meters_Readings__r
          WHERE Month__c = :month AND Year__c = :year
        )
      FROM Communal_Service_User__c
    ];

    List<Communal_Service_User__c> usersWithUnfilledReadings = CommunalServiceUserController.getUsersWithUnfilledReadings(
      communalServiceUsers
    );

    CommunalServiceUserController.notifyUsers(usersWithUnfilledReadings);
  }
}
