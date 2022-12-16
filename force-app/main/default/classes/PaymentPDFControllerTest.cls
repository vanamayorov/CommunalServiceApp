@isTest
private class PaymentPDFControllerTest {
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
      Region__c = kharkivRegion.Id
    );
    insert kharkivCity;

    Communal_Service_User__c communalUser = new Communal_Service_User__c(
      User__c = user.Id,
      Email__c = 'communaluser@gmail.com',
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

    Payment__c payment = new Payment__c(
      Monthly_Bill__c = monthlyBill.Id,
      Status__c = 'Successfully paid',
      Amount__c = 4,
      Date__c = Date.today()
    );
    insert payment;
  }

  @isTest
  static void getFormattedDateTest() {
    Payment__c payment = [
      SELECT
        Id,
        Status__c,
        Amount__c,
        Date__c,
        CurrencyIsoCode,
        Monthly_Bill__c,
        Monthly_Bill__r.Month__c,
        Monthly_Bill__r.Year__c
      FROM Payment__c
      WHERE Status__c = 'Successfully paid'
      LIMIT 1
    ];
    PaymentPDFController controller = new PaymentPDFController();
    controller.payment = payment;
    String formattedDate = controller.getFormattedDate();
    String actualDate = payment.Date__c.format('HH:mm dd.MM.yyyy');
    System.assertEquals(actualDate, formattedDate);
  }
}
