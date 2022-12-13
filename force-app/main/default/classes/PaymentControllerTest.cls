@isTest
private class PaymentControllerTest {
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
      Amount__c = 4,
      Monthly_Bill__c = monthlyBill.Id,
      Status__c = 'Successfully paid',
      Date__c = Date.today()
    );

    insert payment;
  }

  @isTest
  static void getPaymentsTest() {
    Test.startTest();
    User user = [
      SELECT Id, FirstName
      FROM User
      WHERE FirstName = 'Test User'
      LIMIT 1
    ];
    List<Payment__c> payments = PaymentController.getPayments(user.Id);
    System.assertEquals(true, !payments.isEmpty());
    for (Payment__c payment : payments) {
      System.assertEquals(4, payment.Amount__c);
    }
    Test.stopTest();
  }

  @isTest
  static void payForMonthTestPositive() {
    Test.startTest();
    Monthly_Bill__c monthlyBill = [
      SELECT Id, Communal_Service_User__r.Email__c
      FROM Monthly_Bill__c
      WHERE Communal_Service_User__r.Email__c = 'communaluser@gmail.com'
      LIMIT 1
    ];
    Map<String, String> payloadMap = new Map<String, String>{
      'cardNumber' => '1234432112344321',
      'cvv' => '123',
      'owner' => 'John Doe',
      'expiration' => '12/22',
      'amount' => '2',
      'billId' => monthlyBill.Id,
      'email' => monthlyBill.Communal_Service_User__r.Email__c
    };
    PaymentController.Response response = PaymentController.payForMonth(
      JSON.serialize(payloadMap)
    );
    System.assertEquals(true, response.ok);
    System.assertEquals('Successfully paid', response.payload.Status__c);
    System.assertEquals(true, String.isEmpty(response.errorMsg));
    Test.stopTest();
  }

  @isTest
  static void payForMonthTestNegative() {
    Test.startTest();
    Monthly_Bill__c monthlyBill = [
      SELECT Id, Communal_Service_User__r.Email__c
      FROM Monthly_Bill__c
      WHERE Communal_Service_User__r.Email__c = 'communaluser@gmail.com'
      LIMIT 1
    ];
    Map<String, String> payloadMap = new Map<String, String>{
      'cardNumber' => '1111111111111111',
      'cvv' => '123',
      'owner' => 'John Doe',
      'expiration' => '12/22',
      'amount' => '2',
      'billId' => monthlyBill.Id,
      'email' => monthlyBill.Communal_Service_User__r.Email__c
    };
    PaymentController.Response response = PaymentController.payForMonth(
      JSON.serialize(payloadMap)
    );
    System.assertEquals(false, response.ok);
    System.assertEquals('Failed to pay', response.payload.Status__c);
    System.assertEquals(
      'Card number doent`t exist, please try again.',
      response.errorMsg
    );
    Test.stopTest();
  }
}
