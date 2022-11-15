trigger CommunalUserTrigger on Communal_Service_User__c(
  after insert,
  after update,
  before delete
) {
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      CommunalServiceUserTriggerHandler.makeRegionsPrivate(Trigger.old);
      // CommunalServiceUserTriggerHandler.makeUserPrivate(Trigger.old);
    }
  }
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      CommunalServiceUserTriggerHandler.makeRegionsPublic(Trigger.new);
    }
    // CommunalServiceUserTriggerHandler.makeUserPublic(Trigger.new);
  }
}
