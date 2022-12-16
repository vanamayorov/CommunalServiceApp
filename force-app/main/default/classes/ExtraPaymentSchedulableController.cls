public with sharing class ExtraPaymentSchedulableController implements Schedulable {
  private static final Integer BILL_EXPIRY_MAX_DAYS_TO_PAY = 10;

  public void execute(SchedulableContext ctx) {
    List<Monthly_Bill__c> monthlyBillsToEditExtraPayment = new List<Monthly_Bill__c>();
    Integer currentDay = Datetime.now().dayOfYear();

    for (Monthly_Bill__c monthlyBill : [
      SELECT
        Id,
        Added_Extra_Payment__c,
        Extra_Payment__c,
        Created_Date__c,
        Communal_Service_User__r.City__r.Extra_Payment__c
      FROM Monthly_Bill__c
      WHERE Added_Extra_Payment__c = FALSE
    ]) {
      Integer monthlyBillDay = Date.valueOf(monthlyBill.Created_Date__c)
        .dayOfYear();
      if (currentDay - monthlyBillDay > BILL_EXPIRY_MAX_DAYS_TO_PAY) {
        monthlyBill.Added_Extra_Payment__c = true;
        monthlyBill.Extra_Payment__c += monthlyBill.Communal_Service_User__r.City__r.Extra_Payment__c;
        monthlyBillsToEditExtraPayment.add(monthlyBill);
      }
    }

    if (!monthlyBillsToEditExtraPayment.isEmpty()) {
      update monthlyBillsToEditExtraPayment;
    }
  }
}
