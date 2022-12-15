@isTest
private class MonthlyBillControllerTest {
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

    User userKyiv = new User(
      ProfileId = userProfile.Id,
      FirstName = 'Test Kyiv User',
      LastName = 'Org',
      Email = 'test@gmail.com',
      Username = 'testuserkyiv@gmail.com' + System.currentTimeMillis(),
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );

    insert new List<User>{ userKharkiv, userKyiv };

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');

    Region__c kyivRegion = new Region__c(Name = 'Kyiv Oblast');

    insert new List<Region__c>{ kharkivRegion, kyivRegion };

    City__c kharkivCity = new City__c(
      Name = 'Kharkiv',
      Region__c = kharkivRegion.Id
    );

    City__c kyivCity = new City__c(Name = 'Kyiv', Region__c = kyivRegion.Id);

    insert new List<City__c>{ kharkivCity, kyivCity };

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
      City__c = kharkivCity.Id,
      Password__c = '123',
      Login__c = '123'
    );

    Communal_Service_User__c communalUserKyiv = new Communal_Service_User__c(
      User__c = userKyiv.Id,
      City__c = kyivCity.Id,
      Password__c = '123',
      Login__c = '123'
    );
    insert new List<Communal_Service_User__c>{
      communalUserKharkiv,
      communalUserKyiv
    };

    Meters_Reading__c metersReadingsKharkivUser = new Meters_Reading__c(
      Month__c = DateUtility.getMonth(),
      Year__c = DateUtility.getYear(),
      Communal_Service_User__c = communalUserKharkiv.Id,
      Water_Readings__c = 2,
      Gas_Readings__c = 2,
      Electricity_Readings__c = 2
    );
    insert metersReadingsKharkivUser;
  }

  @isTest
  static void createMonthlyBillTestPositive() {
    Test.startTest();
    Monthly_Bill__c monthlyBill = [
      SELECT
        Id,
        Year__c,
        Month__c,
        Gas_Price__c,
        Water_Price__c,
        Electricity_Price__c
      FROM Monthly_Bill__c
      WHERE
        Year__c = :DateUtility.getYear()
        AND Month__c = :DateUtility.getMonth()
      LIMIT 1
    ];
    System.assertEquals(4, monthlyBill.Gas_Price__c);
    System.assertEquals(4, monthlyBill.Water_Price__c);
    System.assertEquals(4, monthlyBill.Electricity_Price__c);
    Test.stopTest();
  }

  @isTest
  static void createMonthlyBillTestException() {
    try {
      Test.startTest();
      Communal_Service_User__c user = [
        SELECT Id, City__r.Name
        FROM Communal_Service_User__c
        WHERE City__r.Name = 'Kyiv'
        LIMIT 1
      ];
      Meters_Reading__c metersReadingsKyivUser = new Meters_Reading__c(
        Month__c = DateUtility.getMonth(),
        Year__c = DateUtility.getYear(),
        Communal_Service_User__c = user.Id,
        Water_Readings__c = 2,
        Gas_Readings__c = 2,
        Electricity_Readings__c = 2
      );
      insert metersReadingsKyivUser;
      Test.stopTest();
    } catch (Exception e) {
      System.assertNotEquals(null, e);
    }
  }
}
