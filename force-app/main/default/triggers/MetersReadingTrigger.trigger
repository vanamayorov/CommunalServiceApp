trigger MetersReadingTrigger on Meters_Reading__c(before insert) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      MonthlyBillController.createMonthlyBill(Trigger.new[0]);
    }
  }
}
