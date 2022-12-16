@isTest
private class ExtraPaymentSchedulableControllerTest {
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

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Email__c = 'communaluser@gmail.com',
      City__c = kharkivCity.Id
    );

    insert communalUser;

    Monthly_Bill__c monthlyBillLate = new Monthly_Bill__c(
      Communal_Service_User__c = communalUser.Id,
      Month__c = 'November',
      Year__c = '2022',
      Electricity_Price__c = 2,
      Gas_Price__c = 2,
      Water_Price__c = 2,
      Created_Date__c = Date.today().addDays(-11)
    );

    Monthly_Bill__c monthlyBillRecent = new Monthly_Bill__c(
      Communal_Service_User__c = communalUser.Id,
      Month__c = 'December',
      Year__c = '2022',
      Electricity_Price__c = 2,
      Gas_Price__c = 2,
      Water_Price__c = 2,
      Created_Date__c = Date.today()
    );

    insert new List<Monthly_Bill__c>{ monthlyBillLate, monthlyBillRecent };
  }

  @isTest
  static void testScheduledJob_Bill_Updated() {
    Test.startTest();
    String jobId = System.schedule(
      'ScheduledApexTest',
      CRON_EXP,
      new ExtraPaymentSchedulableController()
    );
    Test.stopTest();
    Monthly_Bill__c updatedMonthlyBill = [
      SELECT Id, Month__c, Extra_Payment__c, Added_Extra_Payment__c
      FROM Monthly_Bill__c
      WHERE Month__c = 'November'
      LIMIT 1
    ];
    System.assertEquals(true, updatedMonthlyBill.Added_Extra_Payment__c);
    System.assertEquals(20, updatedMonthlyBill.Extra_Payment__c);
  }

  @isTest
  static void testScheduledJob_Bill_NotUpdated() {
    Test.startTest();
    String jobId = System.schedule(
      'ScheduledApexTest',
      CRON_EXP,
      new ExtraPaymentSchedulableController()
    );
    Test.stopTest();
    Monthly_Bill__c updatedMonthlyBill = [
      SELECT Id, Month__c, Extra_Payment__c, Added_Extra_Payment__c
      FROM Monthly_Bill__c
      WHERE Month__c = 'December'
      LIMIT 1
    ];
    System.assertEquals(false, updatedMonthlyBill.Added_Extra_Payment__c);
    System.assertEquals(0, updatedMonthlyBill.Extra_Payment__c);
  }
}
