public with sharing class PaymentService {
  private static final Map<String, Map<String, String>> mockedData = new Map<String, Map<String, String>>{
    '1234432112344321' => new Map<String, String>{
      'cvv' => '123',
      'expiration' => '12/22',
      'owner' => 'John Doe',
      'amount' => '19'
    },
    '1111222233334444' => new Map<String, String>{
      'cvv' => '123',
      'expiration' => '12/22',
      'owner' => 'John Doe',
      'amount' => '100'
    }
  };

  public static PaymentServiceResponse paymentSucceded(
    String cardNumber,
    String cvv,
    String expiration,
    String owner,
    Double amount
  ) {
    try {
      PaymentService.cardExists(cardNumber, cvv, expiration, owner);
      PaymentService.cardHasEnoughMoney(cardNumber, amount);

      return new PaymentServiceResponse(true, '');
    } catch (Exception e) {
      return new PaymentServiceResponse(false, e.getMessage());
    }
  }

  private static Boolean cardExists(
    String cardNumber,
    String cvv,
    String expiration,
    String owner
  ) {
    if (PaymentService.mockedData.keySet().contains(cardNumber)) {
      Map<String, String> cardInfo = PaymentService.mockedData.get(cardNumber);
      if (
        cardInfo.get('cvv') == cvv &&
        cardInfo.get('expiration') == expiration &&
        cardInfo.get('owner') == owner
      ) {
        return true;
      }
      throw new CustomException('Card info is incorrect, please try again.');
    }

    throw new CustomException('Card number doent`t exist, please try again.');
  }

  private static Boolean cardHasEnoughMoney(String cardNumber, Double amount) {
    if (
      Double.valueOf(PaymentService.mockedData.get(cardNumber).get('amount')) -
      amount >= 0
    ) {
      return true;
    }

    throw new CustomException('Not enough measures on a card balance.');
  }
}
