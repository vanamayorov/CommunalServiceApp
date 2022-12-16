@isTest
private class RegionManagerControllerTest {
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

    User userManager = new User(
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

    insert new List<User>{ user, userManager };

    Region_Manager__c regManager = new Region_Manager__c(
      User__c = userManager.Id,
      First_Name__c = 'Test',
      Last_Name__c = 'Manager',
      Email__c = 'testmanager@gmail.com'
    );

    insert regManager;

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Region_Manager__c = regManager.Id,
      Password__c = '123',
      Login__c = '123'
    );

    insert communalUser;
  }

  @isTest
  static void getRegionManagerByUserIdTestPositive() {
    Test.startTest();
    Communal_Service_User__c communalUser = [
      SELECT Id, User__c, Region_Manager__r.Email__c, User__r.Email
      FROM Communal_Service_User__c
      WHERE Region_Manager__r.Email__c = 'testmanager@gmail.com'
      LIMIT 1
    ];
    Communal_Service_User__c userWithManager = RegionManagerController.getRegionManagerByUserId(
      communalUser.User__c
    );
    System.assertEquals(
      communalUser.Region_Manager__r.Email__c,
      userWithManager.Region_Manager__r.Email__c
    );
    Test.stopTest();
  }

  @isTest
  static void getRegionManagerByUserIdTestException() {
    Test.startTest();
    try {
      Communal_Service_User__c userWithManager = RegionManagerController.getRegionManagerByUserId(
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
  static void contactManagerTestPositive() {
    Test.startTest();
    Communal_Service_User__c communalUser = [
      SELECT Id, Region_Manager__r.Email__c, User__c, User__r.Email
      FROM Communal_Service_User__c
      WHERE Region_Manager__r.Email__c = 'testmanager@gmail.com'
      LIMIT 1
    ];
    Map<String, String> payloadMap = new Map<String, String>{
      'managerEmail' => communalUser.Region_Manager__r.Email__c,
      'message' => 'test message',
      'subject' => 'test subject',
      'userEmail' => communalUser.User__r.Email
    };
    Map<String, Boolean> res = RegionManagerController.contactManager(
      JSON.serialize(payloadMap)
    );
    System.assertEquals(true, res.get('sentSuccessfully'));
    Test.stopTest();
  }

  @isTest
  static void contactManagerTestException() {
    try {
      Test.startTest();
      Communal_Service_User__c communalUser = [
        SELECT Id, Region_Manager__r.Email__c, User__r.Email
        FROM Communal_Service_User__c
        WHERE Region_Manager__r.Email__c = 'testmanager@gmail.com'
        LIMIT 1
      ];
      Map<String, String> payloadMap = new Map<String, String>{
        'managerEmail' => '',
        'message' => 'test message',
        'subject' => 'test subject',
        'userEmail' => communalUser.User__r.Email
      };
      Map<String, Boolean> res = RegionManagerController.contactManager(
        JSON.serialize(payloadMap)
      );
      Test.stopTest();
    } catch (Exception e) {
      System.assertNotEquals(null, e);
      System.assertEquals(true, e.getMessage().startsWith('SendEmail failed'));
    }
  }
}
