public with sharing class EmailService {
  public static List<Messaging.SendEmailResult> sendEmail(
    String senderAddress,
    String receiverAddress,
    String subject,
    String message
  ) {
    try {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ receiverAddress };
      mail.setToAddresses(toAddresses);
      mail.setSubject(subject);
      mail.setHtmlBody(message);
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ mail }
      );
      return results;
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
