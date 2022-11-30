public with sharing class PaymentPDFController {
  public Payment__c payment { get; set; }
  public PaymentPDFController() {
    String paymentId = ApexPages.currentPage().getParameters().get('paymentId');
    this.payment = [
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
      WHERE Id = :paymentId
      LIMIT 1
    ];
  }

  @Future(callout=true)
  public static void generatePDF(String paymentId, String email) {
    PageReference invoicePDF = new PageReference(
      '/apex/PaymentPDFView?paymentId=' + paymentId
    );

    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    attachment.setContentType('application/pdf');
    attachment.setFileName('Invoice PDF');
    attachment.body = invoicePDF.getContent();
    attachment.setInline(false);

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{ email });
    mail.setSubject('Invoice PDF');
    mail.setHtmlBody('The Invoice PDF');
    mail.setFileAttachments(
      new List<Messaging.EmailFileAttachment>{ attachment }
    );
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }

  public String getFormattedDate() {
    return this.payment.Date__c.format('HH:mm dd.MM.yyyy');
  }
}
