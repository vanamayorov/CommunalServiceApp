@isTest
private class EmailServiceTest {
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
      Email__c = 'communaluser@gmail.com',
      Region_Manager__c = regKharkivManager.Id,
      Region__c = kharkivRegion.Id,
      City__c = kharkivCity.Id
    );

    insert communalUser;
  }

  @isTest
  static void sendEmailTest() {
    Test.startTest();
    Communal_Service_User__c communalUser = [
      SELECT Id, Email__c, Region_Manager__r.Email__c
      FROM Communal_Service_User__c
      WHERE Email__c = 'communaluser@gmail.com'
      LIMIT 1
    ];

    String subject = 'TEST SUBJECT';
    String message = 'TEST MESSAGE';
    List<Messaging.SendEmailResult> res = EmailService.sendEmail(
      communalUser.Email__c,
      communalUser.Region_Manager__r.Email__c,
      subject,
      message
    );
    System.assertNotEquals(null, res);
    System.assertEquals(1, res.size());
    Test.stopTest();
  }
}
