@isTest
private class RegionControllerTest {
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
      Username = 'testmanagerorg@gmail.com' + System.currentTimeMillis(),
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
      Username = 'testmanagerorg@gmail.com' + System.currentTimeMillis(),
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
      Region__c = kharkivRegion.Id
    );

    insert kharkivCity;

    Region_Manager__c regKharkivManager = new Region_Manager__c(
      User__c = userManagerFromKharkiv.Id,
      Region__c = kharkivRegion.Id,
      First_Name__c = 'Kharkiv',
      Last_Name__c = 'Manager',
      Email__c = 'kharkivmanager@gmail.com'
    );

    insert regKharkivManager;

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Region_Manager__c = regKharkivManager.Id,
      Region__c = kharkivRegion.Id,
      City__c = kharkivCity.Id,
      Password__c = '123',
      Login__c = '123'
    );

    insert communalUser;
  }

  @isTest
  static void getRegionsTest() {
    Test.startTest();
    List<Region__c> regions = RegionController.getRegions();
    System.assertEquals(true, !regions.isEmpty());
    System.assertEquals(1, regions.size());
    for (Region__c reg : regions) {
      System.assertEquals('Kharkiv Oblast', reg.Name);
      System.assertEquals(true, !reg.Region_Managers__r.isEmpty());
      System.assertEquals(1, reg.Region_Managers__r.size());
      System.assertEquals(true, !reg.Cities__r.isEmpty());
      System.assertEquals(1, reg.Cities__r.size());
    }
    Test.stopTest();
  }
}
