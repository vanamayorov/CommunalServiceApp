@isTest
private class CommunalRateTriggerTest {
  @testSetup
  static void setup() {
    Profile regionManagerProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'Communal Service Manager'
    ];

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
    User userManagerFromKyiv = new User(
      ProfileId = regionManagerProfile.Id,
      FirstName = 'Test Kyiv',
      LastName = 'Manager',
      Email = 'testmanager@gmail.com',
      Username = 'testmanagerorgkyiv@gmail.com' + System.currentTimeMillis(),
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    insert new List<User>{ userManagerFromKharkiv, userManagerFromKyiv };

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');
    Region__c kyivRegion = new Region__c(Name = 'Kyiv Oblast');
    insert new List<Region__c>{ kharkivRegion, kyivRegion };

    City__c kharkivCity = new City__c(
      Name = 'Kharkiv',
      Region__c = kharkivRegion.Id
    );
    City__c kyivCity = new City__c(Name = 'Kyiv', Region__c = kyivRegion.Id);
    insert new List<City__c>{ kyivCity, kharkivCity };

    Region_Manager__c regKharkivManager = new Region_Manager__c(
      User__c = userManagerFromKharkiv.Id,
      Region__c = kharkivRegion.Id,
      First_Name__c = 'Kharkiv',
      Last_Name__c = 'Manager',
      Email__c = 'kharkivmanager@gmail.com'
    );
    Region_Manager__c regKyivManager = new Region_Manager__c(
      User__c = userManagerFromKyiv.Id,
      Region__c = kyivRegion.Id,
      First_Name__c = 'Kyiv',
      Last_Name__c = 'Manager',
      Email__c = 'kyivmanager@gmail.com'
    );
    insert new List<Region_Manager__c>{ regKharkivManager, regKyivManager };

    Communal_Rates__c rateForKharkiv = new Communal_Rates__c(
      City__c = kharkivCity.Id,
      Month__c = 'December',
      Year__c = '2022',
      Gas_Rate__c = 4,
      Water_Rate__c = 4,
      Electricity_Rate_per_kWh__c = 4
    );

    Communal_Rates__c rateForKyiv = new Communal_Rates__c(
      City__c = kyivCity.Id,
      Month__c = 'December',
      Year__c = '2022',
      Gas_Rate__c = 4,
      Water_Rate__c = 4,
      Electricity_Rate_per_kWh__c = 4
    );
    insert new List<Communal_Rates__c>{ rateForKharkiv, rateForKyiv };
  }

  @isTest
  static void communalRateUpdateTestPositive() {
    Test.startTest();
    Communal_Rates__c rate = [
      SELECT Id, Month__c, Gas_Rate__c
      FROM Communal_Rates__c
      WHERE Month__c = 'December'
      LIMIT 1
    ];
    rate.Gas_Rate__c = 5;
    update rate;
    rate = [
      SELECT Id, Month__c, Gas_Rate__c
      FROM Communal_Rates__c
      WHERE Month__c = 'December'
      LIMIT 1
    ];
    System.assertEquals(5, rate.Gas_Rate__c);
    System.assertNotEquals(4, rate.Gas_Rate__c);
    Test.stopTest();
  }

  @isTest
  static void communalRateUpdateTestError() {
    try {
      Test.startTest();
      Communal_Rates__c rate = [
        SELECT Id, Month__c, City__r.Name, Gas_Rate__c
        FROM Communal_Rates__c
        WHERE City__r.Name = 'Kyiv'
        LIMIT 1
      ];
      rate.Gas_Rate__c = 5;
      update rate;
      Test.stopTest();
    } catch (Exception e) {
      System.assertNotEquals(null, e);
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'You cannot change rates in the region where you are not a manager'
          )
      );
    }
  }
}
