@isTest
private class MetersReadingsNotificationControllerTest {
  private static String CRON_EXP = '0 0 0 9 12 ? 2023';
  @testSetup
  static void setup() {
    Profile userProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'Communal Service User'
    ];

    User user = new User(
      ProfileId = userProfile.Id,
      FirstName = 'Test User',
      LastName = 'Org',
      Email = 'test@gmail.com',
      Username = 'testuserorg@gmail.com' + System.currentTimeMillis(),
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );

    insert user;

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');

    insert kharkivRegion;

    City__c kharkivCity = new City__c(
      Name = 'Kharkiv',
      Region__c = kharkivRegion.Id,
      Extra_Payment__c = 20
    );
    insert kharkivCity;

    Communal_Rates__c communalRate = new Communal_Rates__c(
      Electricity_Rate_per_kWh__c = 2,
      Gas_Rate__c = 2,
      Water_Rate__c = 2,
      Year__c = DateUtility.getYear(),
      Month__c = DateUtility.getMonth(),
      City__c = kharkivCity.Id
    );
    insert communalRate;

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Email__c = 'communaluser@gmail.com',
      City__c = kharkivCity.Id
    );
    insert communalUser;

    Meters_Reading__c metersReadings = new Meters_Reading__c(
      Month__c = DateUtility.getMonth(),
      Year__c = DateUtility.getYear(),
      Communal_Service_User__c = communalUser.Id,
      Water_Readings__c = 2,
      Gas_Readings__c = 2,
      Electricity_Readings__c = 2
    );
    insert metersReadings;
  }

  @isTest
  static void testScheduledJob() {
    Test.startTest();
    String jobId = System.schedule(
      'MetersReadingsNotificationControllerTest',
      CRON_EXP,
      new MetersReadingsNotificationController()
    );
    System.assertNotEquals(null, jobId);
    Test.stopTest();
  }
}
