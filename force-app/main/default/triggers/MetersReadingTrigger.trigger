trigger MetersReadingTrigger on Meters_Reading__c(before insert, after insert) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      MonthlyBillController.createMonthlyBill(Trigger.new[0]);
    }
  }

  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      List<Update_After_Filling_MetersReadings__e> events = new List<Update_After_Filling_MetersReadings__e>();
      events.add(new Update_After_Filling_MetersReadings__e());
      List<Database.SaveResult> results = EventBus.publish(events);
    }
  }
}
