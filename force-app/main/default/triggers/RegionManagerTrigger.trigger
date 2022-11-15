trigger RegionManagerTrigger on Region_Manager__c(
  after insert,
  after update,
  before delete
) {
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      RegionManagerTriggerHandler.makeRegionPrivate(Trigger.old);
    }
  }
  if (Trigger.isAfter) {
    RegionManagerTriggerHandler.makeRegionPublic(Trigger.new);
  }
}
