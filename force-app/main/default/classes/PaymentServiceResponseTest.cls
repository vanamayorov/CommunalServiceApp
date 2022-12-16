@isTest
private class PaymentServiceResponseTest {
  @isTest
  static void createPaymentServiceResponse() {
    PaymentServiceResponse resp = new PaymentServiceResponse(true, '');
    System.assertEquals(true, resp.success);
    System.assertEquals(true, String.isEmpty(resp.errorMessage));
  }
}
