trigger CommunalUserTrigger on Communal_Service_User__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete
) {
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      CommunalServiceUserTriggerHandler.makeUserPrivate(Trigger.old);
    }
    if (Trigger.isInsert || Trigger.isUpdate) {
      CommunalServiceUserTriggerHandler.checkIfUserOwnerHasOtherUsers(
        Trigger.new
      );
    }
  }
  if (Trigger.isAfter) {
    CommunalServiceUserTriggerHandler.makeUserPublic(Trigger.new);
  }
}
