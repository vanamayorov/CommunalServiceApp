@isTest
private class MetersReadingTriggerTest {
  @testSetup
  static void setup() {
    Profile userProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'Communal Service User'
    ];

    User userKharkiv = new User(
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

    insert userKharkiv;

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');

    insert kharkivRegion;

    City__c kharkivCity = new City__c(
      Name = 'Kharkiv',
      Region__c = kharkivRegion.Id
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

    Communal_Service_User__c communalUserKharkiv = new Communal_Service_User__c(
      User__c = userKharkiv.Id,
      Email__c = 'communaluser@gmail.com',
      City__c = kharkivCity.Id
    );

    insert communalUserKharkiv;
  }

  @isTest
  static void insertMetersReadingsTest() {
    Test.startTest();
    Communal_Service_User__c communalUserKharkiv = [
      SELECT Id, Email__c
      FROM Communal_Service_User__c
      WHERE Email__c = 'communaluser@gmail.com'
      LIMIT 1
    ];
    Meters_Reading__c metersReadingsKharkivUser = new Meters_Reading__c(
      Month__c = DateUtility.getMonth(),
      Year__c = DateUtility.getYear(),
      Communal_Service_User__c = communalUserKharkiv.Id,
      Water_Readings__c = 2,
      Gas_Readings__c = 2,
      Electricity_Readings__c = 2
    );
    insert metersReadingsKharkivUser;

    Monthly_Bill__c monthlyBill = [
      SELECT
        Id,
        Electricity_Price__c,
        Gas_Price__c,
        Water_Price__c,
        Year__c,
        Month__c
      FROM Monthly_Bill__c
      WHERE Year__c = :DateUtility.getYear()
      LIMIT 1
    ];
    System.assertEquals(4, monthlyBill.Gas_Price__c);
    System.assertEquals(4, monthlyBill.Water_Price__c);
    System.assertEquals(4, monthlyBill.Electricity_Price__c);
    Test.stopTest();
  }
}
