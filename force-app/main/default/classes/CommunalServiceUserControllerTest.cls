@isTest
private class CommunalServiceUserControllerTest {
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

    insert new List<User>{ user, userManagerFromKharkiv, userManagerFromKyiv };

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');

    Region__c kyivRegion = new Region__c(Name = 'Kyiv Oblast');

    insert new List<Region__c>{ kharkivRegion, kyivRegion };

    City__c kharkivCity = new City__c(
      Name = 'Kharkiv',
      Region__c = kharkivRegion.Id
    );

    City__c kyivCity = new City__c(Name = 'Kyiv', Region__c = kyivRegion.Id);

    insert new List<City__c>{ kharkivCity, kyivCity };

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

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Email__c = 'communaluser@gmail.com',
      Region_Manager__c = regKharkivManager.Id,
      Region__c = kharkivRegion.Id,
      City__c = kharkivCity.Id
    );

    insert communalUser;

    Monthly_Bill__c monthlyBill = new Monthly_Bill__c(
      Communal_Service_User__c = communalUser.Id,
      Month__c = 'November',
      Year__c = '2022',
      Electricity_Price__c = 2,
      Gas_Price__c = 2,
      Water_Price__c = 2,
      Created_Date__c = Date.today()
    );

    insert monthlyBill;
  }

  @isTest
  static void getUserEmailTestPositive() {
    Test.startTest();
    Communal_Service_User__c user = [
      SELECT Id, Email__c, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
      LIMIT 1
    ];
    String actualEmail = CommunalServiceUserController.getUserEmail(
      user.User__c
    );
    System.assertEquals(user.Email__c, actualEmail);
    Test.stopTest();
  }

  @isTest
  static void getUserEmailTestNegative() {
    Test.startTest();
    try {
      String email = CommunalServiceUserController.getUserEmail('wrongUserId');
      System.assert(
        false,
        'Unreachable statement, the method should have thrown an exception'
      );
    } catch (Exception e) {
      System.assertEquals(
        'Communal Service User with userId: wrongUserId was not found',
        e.getMessage()
      );
    }
    Test.stopTest();
  }

  @isTest
  static void userHasDebtTestPositive() {
    Test.startTest();
    Communal_Service_User__c user = [
      SELECT Id, Email__c, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
      LIMIT 1
    ];
    Map<String, Boolean> debtMap = CommunalServiceUserController.userHasDebt(
      user.User__c
    );
    System.assertNotEquals(null, debtMap);
    System.assertEquals(true, debtMap.get('result'));
    Test.stopTest();
  }

  @isTest
  static void userHasDebtTestNegative() {
    Test.startTest();
    try {
      Map<String, Boolean> debtMap = CommunalServiceUserController.userHasDebt(
        'wrongUserId'
      );
      System.assert(
        false,
        'Unreachable statement, the method should have thrown an exception'
      );
    } catch (Exception e) {
      System.assertEquals(
        'Communal Service User with userId: wrongUserId was not found',
        e.getMessage()
      );
    }
    Test.stopTest();
  }

  @isTest
  static void getUnpaidMonthlyBillsTestPositive() {
    Test.startTest();
    Communal_Service_User__c user = [
      SELECT Id, Email__c, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
      LIMIT 1
    ];
    List<Monthly_Bill__c> monthlyBills = CommunalServiceUserController.getUnpaidMonthlyBills(
      user.User__c
    );
    System.assertEquals(true, !monthlyBills.isEmpty());
    Test.stopTest();
  }

  @isTest
  static void getUnpaidMonthlyBillsTestException() {
    Test.startTest();
    try {
      List<Monthly_Bill__c> monthlyBills = CommunalServiceUserController.getUnpaidMonthlyBills(
        null
      );
    } catch (Exception e) {
      System.assertNotEquals(null, e);
      System.assertEquals(true, String.isBlank(e.getMessage()));
    }
    Test.stopTest();
  }

  @isTest
  static void changeAddressTestPositive() {
    Test.startTest();
    Communal_Service_User__c user = [
      SELECT Id, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
      LIMIT 1
    ];

    Region__c region = [
      SELECT
        Id,
        Name,
        (SELECT Id FROM Region_Managers__r LIMIT 1),
        (SELECT Id FROM Cities__r LIMIT 1)
      FROM Region__c
      WHERE Name = 'Kyiv Oblast'
      LIMIT 1
    ];

    Map<String, String> payloadMap = new Map<String, String>{
      'userId' => user.User__c,
      'regionId' => region.Id,
      'cityId' => region.Cities__r[0].Id,
      'managerId' => region.Region_Managers__r[0].Id
    };

    Communal_Service_User__c changedUser = CommunalServiceUserController.changeAddress(
      JSON.serialize(payloadMap)
    );
    System.assertEquals(user.Id, changedUser.Id);
    System.assertEquals(region.Id, changedUser.Region__c);
    System.assertEquals(region.Cities__r[0].Id, changedUser.City__c);
    System.assertEquals(
      region.Region_Managers__r[0].Id,
      changedUser.Region_Manager__c
    );
    Test.stopTest();
  }

  @isTest
  static void changeAddressTestException() {
    Test.startTest();
    try {
      Communal_Service_User__c user = [
        SELECT Id, User__r.FirstName, User__c
        FROM Communal_Service_User__c
        WHERE User__r.FirstName = 'Test User'
        LIMIT 1
      ];

      Region__c region = [
        SELECT
          Id,
          Name,
          (SELECT Id FROM Region_Managers__r LIMIT 1),
          (SELECT Id FROM Cities__r LIMIT 1)
        FROM Region__c
        WHERE Name = 'Kyiv Oblast'
        LIMIT 1
      ];

      Map<String, String> payloadMap = new Map<String, String>{
        'userId' => 'wrongUserId',
        'regionId' => region.Id,
        'cityId' => region.Cities__r[0].Id,
        'managerId' => region.Region_Managers__r[0].Id
      };

      Communal_Service_User__c changedUser = CommunalServiceUserController.changeAddress(
        JSON.serialize(payloadMap)
      );
      System.assert(
        false,
        'Unreachable statement, the method should have thrown an exception'
      );
    } catch (Exception e) {
      System.assertEquals(
        'Communal Service User with userId: wrongUserId was not found',
        e.getMessage()
      );
    }
    Test.stopTest();
  }

  @isTest
  static void getCommunalServiceUserRegionTestPositive() {
    Test.startTest();
    Communal_Service_User__c user = [
      SELECT Id, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
      LIMIT 1
    ];
    Communal_Service_User__c res = CommunalServiceUserController.getCommunalServiceUserRegion(
      user.User__c
    );
    String expectedRegion = 'Kharkiv Oblast';
    String expectedCity = 'Kharkiv';
    System.assertEquals(expectedRegion, res.Region__r.Name);
    System.assertEquals(expectedCity, res.City__r.Name);
    Test.stopTest();
  }

  @isTest
  static void getCommunalServiceUserRegionTestException() {
    Test.startTest();
    try {
      Communal_Service_User__c res = CommunalServiceUserController.getCommunalServiceUserRegion(
        'wrongUserId'
      );
      System.assert(
        false,
        'Unreachable statement, the method should have thrown an exception'
      );
    } catch (Exception e) {
      System.assertEquals(
        'Communal Service User with userId: wrongUserId was not found',
        e.getMessage()
      );
    }
    Test.stopTest();
  }

  @isTest
  static void notifyUsersTestPositive() {
    Test.startTest();
    List<Communal_Service_User__c> users = [
      SELECT Id, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
    ];
    List<Messaging.SendEmailResult> res = CommunalServiceUserController.notifyUsers(
      users
    );
    System.assertNotEquals(null, res);
    System.assertEquals(users.size(), res.size());
    Test.stopTest();
  }

  @isTest
  static void getUsersWithUnfilledReadingsTestPositive() {
    Test.startTest();
    List<Communal_Service_User__c> users = [
      SELECT Id, User__r.FirstName, User__c
      FROM Communal_Service_User__c
      WHERE User__r.FirstName = 'Test User'
    ];

    List<Communal_Service_User__c> res = CommunalServiceUserController.getUsersWithUnfilledReadings(
      users
    );
    System.assertNotEquals(null, res);
    System.assertEquals(users.size(), res.size());
    Test.stopTest();
  }
}
