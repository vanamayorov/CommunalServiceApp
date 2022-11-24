trigger CommunalUserTrigger on Communal_Service_User__c(
  after insert,
  after update,
  before delete
) {
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      // CommunalServiceUserTriggerHandler.makeUserPrivate(Trigger.old);
    }
  }
  if (Trigger.isAfter) {
    // CommunalServiceUserTriggerHandler.makeUserPublic(Trigger.new);
  }
}
