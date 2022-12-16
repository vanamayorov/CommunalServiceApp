@isTest
private class PaymentServiceTest {
  @isTest
  static void paymentSuccededTestPositive() {
    PaymentServiceResponse res = PaymentService.paymentSucceded(
      '1234432112344321',
      '123',
      '12/22',
      'John Doe',
      19
    );
    System.assertEquals(true, res.success);
    System.assertEquals(true, String.isEmpty(res.errorMessage));
  }

  @isTest
  static void paymentSuccededTestNegative_Card_Info() {
    PaymentServiceResponse res = PaymentService.paymentSucceded(
      '1234432112344321',
      '222',
      '12/22',
      'John Doe',
      19
    );
    System.assertEquals(false, res.success);
    System.assertEquals(
      'Card info is incorrect, please try again.',
      res.errorMessage
    );
  }

  @isTest
  static void paymentSuccededTestNegative_Enough_Money() {
    PaymentServiceResponse res = PaymentService.paymentSucceded(
      '1234432112344321',
      '123',
      '12/22',
      'John Doe',
      29
    );
    System.assertEquals(false, res.success);
    System.assertEquals(
      'Not enough measures on a card balance.',
      res.errorMessage
    );
  }
}
