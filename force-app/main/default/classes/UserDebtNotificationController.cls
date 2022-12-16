public with sharing class UserDebtNotificationController implements Schedulable {
  public void execute(SchedulableContext ctx) {
    SendNotificationsToUserAndManController myBatchObject = new SendNotificationsToUserAndManController();
    Id batchId = Database.executeBatch(myBatchObject);
  }
}
