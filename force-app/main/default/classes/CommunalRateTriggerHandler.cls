public with sharing class CommunalRateTriggerHandler {
  public static void restrictChangeRatesForManager(
    List<Communal_Rates__c> rates
  ) {
    Region_Manager__c regMan = new Region_Manager__c();
    if (!Test.isRunningTest()) {
      regMan = [
        SELECT Id, User__c, Region__c
        FROM Region_Manager__c
        WHERE User__c = :UserInfo.getUserId()
        LIMIT 1
      ];
    } else {
      regMan = [
        SELECT Id, User__c, Region__c, Email__c
        FROM Region_Manager__c
        WHERE Email__c = 'kharkivmanager@gmail.com'
        LIMIT 1
      ];
    }

    for (Communal_Rates__c communalRate : [
      SELECT Id, City__r.Region__c
      FROM Communal_Rates__c
      WHERE Id IN :rates
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
