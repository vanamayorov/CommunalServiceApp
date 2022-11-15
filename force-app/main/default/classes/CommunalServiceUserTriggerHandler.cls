public with sharing class CommunalServiceUserTriggerHandler {
  // public static void makeUserPublic(List<Communal_Service_User__c> users) {
  //   List<Communal_Service_User__Share> usersShareList = new List<Communal_Service_User__Share>();
  //   for (Communal_Service_User__c user : users) {
  //     Communal_Service_User__Share userShare = new Communal_Service_User__Share();
  //     userShare.ParentId = user.Id;
  //     userShare.UserOrGroupId = user.User__c;
  //     userShare.AccessLevel = 'Read';
  //     usersShareList.add(userShare);
  //   }
  //   if (!usersShareList.isEmpty())
  //     upsert usersShareList;
  // }

  // public static void makeUserPrivate(List<Communal_Service_User__c> users) {
  //   Set<Id> uIds = new Set<Id>();

  //   for (Communal_Service_User__c user : users) {
  //     uIds.add(user.User__c);
  //   }

  //   List<Communal_Service_User__Share> userShareList = [
  //     SELECT Id, UserOrGroupId
  //     FROM Communal_Service_User__Share
  //     WHERE UserOrGroupId IN :uIds
  //   ];

  //   delete userShareList;
  // }

  public static void makeRegionsPublic(List<Communal_Service_User__c> users) {
    List<Region__Share> regionShareList = new List<Region__Share>();
    List<Region__c> regions = [SELECT Id FROM Region__c];
    Set<Id> regionsIds = new Set<Id>();

    for (Region__c region : regions) {
      regionsIds.add(region.Id);
    }

    for (Communal_Service_User__c user : users) {
      for (Id regionId : regionsIds) {
        Region__Share regionShare = new Region__Share();
        regionShare.ParentId = regionId;
        regionShare.UserOrGroupId = user.User__c;
        regionShare.AccessLevel = 'Read';
        regionShareList.add(regionShare);
      }
    }
    if (!regionShareList.isEmpty())
      insert regionShareList;
  }

  public static void makeRegionsPrivate(List<Communal_Service_User__c> users) {
    Set<Id> uIds = new Set<Id>();

    for (Communal_Service_User__c user : users) {
      uIds.add(user.User__c);
    }

    List<Region__Share> regionShareList = [
      SELECT Id, UserOrGroupId
      FROM Region__Share
      WHERE UserOrGroupId IN :uIds
    ];

    delete regionShareList;
  }
}
