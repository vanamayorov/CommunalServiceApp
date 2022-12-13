@isTest
private class CommunalUserTriggerTest {
  @TestSetup
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
    insert new List<User>{ user, userManagerFromKharkiv, userManagerFromKyiv };

    Region__c kharkivRegion = new Region__c(Name = 'Kharkiv Oblast');
    Region__c kyivRegion = new Region__c(Name = 'Kyiv Oblast');
    insert new List<Region__c>{ kyivRegion, kharkivRegion };

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
      Email__c = 'communaluserkyiv@gmail.com',
      Region_Manager__c = regKyivManager.Id,
      Region__c = kyivRegion.Id,
      City__c = kyivCity.Id
    );

    insert communalUser;
  }
  @isTest
  static void insertUserTest() {
    Test.startTest();
    User user = [
      SELECT Id, FirstName
      FROM User
      WHERE FirstName = 'Test User'
      LIMIT 1
    ];
    Region_Manager__c regKharkivManager = [
      SELECT Id, Email__c, Region__c
      FROM Region_Manager__c
      WHERE Email__c = 'kharkivmanager@gmail.com'
      LIMIT 1
    ];
    City__c city = [SELECT Id, Name FROM City__c WHERE Name = 'Kyiv' LIMIT 1];
    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Email__c = 'communaluser@gmail.com',
      Region_Manager__c = regKharkivManager.Id,
      Region__c = regKharkivManager.Region__c,
      City__c = city.Id
    );
    insert communalUser;

    List<Communal_Service_User__Share> shareRules = [
      SELECT Id, ParentId, UserOrGroupId
      FROM Communal_Service_User__Share
      WHERE ParentId = :communalUser.Id AND RowCause = 'Manual'
    ];

    System.assertNotEquals(null, shareRules);
    System.assertEquals(true, !shareRules.isEmpty());
    Test.stopTest();
  }

  @isTest
  static void deleteUserTest() {
    Test.startTest();
    Communal_Service_User__c communalUser = [
      SELECT Id, Email__c
      FROM Communal_Service_User__c
      WHERE Email__c = 'communaluserkyiv@gmail.com'
      LIMIT 1
    ];

    delete communalUser;
    List<Communal_Service_User__Share> shareRules = [
      SELECT Id, ParentId, UserOrGroupId
      FROM Communal_Service_User__Share
      WHERE RowCause = 'Manual'
    ];

    System.assertEquals(true, shareRules.isEmpty());
    Test.stopTest();
  }
}
