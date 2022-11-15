public with sharing class RegionManagerTriggerHandler {
  public static void makeRegionPublic(List<Region_Manager__c> regionManagers) {
    List<Region__Share> regionShareList = new List<Region__Share>();
    for (Region_Manager__c regionMan : regionManagers) {
      Region__Share regionShare = new Region__Share();
      regionShare.ParentId = regionMan.Region__c;
      regionShare.UserOrGroupId = regionMan.User__c;
      regionShare.AccessLevel = 'Read';
      regionShareList.add(regionShare);
    }
    if (!regionShareList.isEmpty())
      upsert regionShareList;
  }

  public static void makeRegionPrivate(List<Region_Manager__c> regionManagers) {
    Set<Id> rMaIds = new Set<Id>();

    for (Region_Manager__c regMan : regionManagers) {
      rMaIds.add(regMan.User__c);
    }

    List<Region__Share> regionShareList = [
      SELECT Id, UserOrGroupId
      FROM Region__Share
      WHERE UserOrGroupId IN :rMaIds
    ];

    delete regionShareList;
  }
}
