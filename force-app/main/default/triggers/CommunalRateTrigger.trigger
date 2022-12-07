trigger CommunalRateTrigger on Communal_Rates__c(before update) {
  String userProfileName = [
    SELECT Id, Name
    FROM profile
    WHERE Id = :userinfo.getProfileId()
  ]
  .Name;

  if (userProfileName == 'System Administrator') {
    return;
  }

  if (Trigger.isBefore) {
    if (Trigger.isUpdate) {
      String userId = UserInfo.getUserId();
      Region_Manager__c regMan = [
        SELECT Id, User__c, Region__c
        FROM Region_Manager__c
        WHERE User__c = :userId
        LIMIT 1
      ];

      for (Communal_Rates__c communalRate : [
        SELECT Id, City__r.Region__c
        FROM Communal_Rates__c
        WHERE Id IN :Trigger.new
      ]) {
        if (communalRate.City__r.Region__c != regMan.Region__c) {
          Trigger.newMap
            .get(communalRate.Id)
            .addError(
              'You cannot change rates in the region where you are not a manager'
            );
        }
      }
    }
  }
}
