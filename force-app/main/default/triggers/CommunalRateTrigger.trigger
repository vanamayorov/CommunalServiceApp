trigger CommunalRateTrigger on Communal_Rates__c(before update) {
  String userProfileName = [
    SELECT Id, Name
    FROM profile
    WHERE Id = :userinfo.getProfileId()
  ]
  .Name;

  if (userProfileName == 'System Administrator' && !Test.isRunningTest()) {
    return;
  }

  if (Trigger.isBefore) {
    if (Trigger.isUpdate) {
      CommunalRateTriggerHandler.restrictChangeRatesForManager(Trigger.new);
    }
  }
}
