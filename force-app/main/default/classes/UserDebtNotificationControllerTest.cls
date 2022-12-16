@isTest
private class UserDebtNotificationControllerTest {
  private static String CRON_EXP = '0 0 0 9 12 ? 2023';
  @testSetup
  static void setup() {
    Profile userProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'Communal Service User'
    ];
    Profile regionManagerProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'Communal Service Manager'
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

    User userManagerFromKharkiv = new User(
      ProfileId = regionManagerProfile.Id,
      FirstName = 'Test Kharkiv',
      LastName = 'Manager',
      Email = 'testmanager@gmail.com',
      Username = 'testmanagerorgkharkiv@gmail.com' + System.currentTimeMillis(),
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );

    insert new List<User>{ user, userManagerFromKharkiv };

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');

    insert kharkivRegion;

    City__c kharkivCity = new City__c(
      Name = 'Kharkiv',
      Region__c = kharkivRegion.Id,
      Extra_Payment__c = 20,
      City_Limit__c = 100
    );
    insert kharkivCity;

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Region__c = kharkivRegion.Id,
      Email__c = 'communaluser@gmail.com',
      City__c = kharkivCity.Id
    );
    insert communalUser;

    Monthly_Bill__c monthlyBill = new Monthly_Bill__c(
      Communal_Service_User__c = communalUser.Id,
      Month__c = 'November',
      Year__c = '2022',
      Electricity_Price__c = 200,
      Gas_Price__c = 200,
      Water_Price__c = 200,
      Created_Date__c = Date.today()
    );

    insert monthlyBill;
  }

  @isTest
  static void testScheduledJob() {
    Test.startTest();
    String jobId = System.schedule(
      'UserDebtNotificationControllerTest',
      CRON_EXP,
      new UserDebtNotificationController()
    );
    System.assertNotEquals(null, jobId);
    Test.stopTest();
  }
}
