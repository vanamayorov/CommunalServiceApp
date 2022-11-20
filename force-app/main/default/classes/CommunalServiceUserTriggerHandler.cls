public with sharing class CommunalServiceUserTriggerHandler {
  public static void makeUserPublic(List<Communal_Service_User__c> users) {
    List<Communal_Service_User__Share> usersShareList = new List<Communal_Service_User__Share>();
    for (Communal_Service_User__c user : users) {
      Communal_Service_User__Share userShare = new Communal_Service_User__Share();
      userShare.ParentId = user.Id;
      userShare.UserOrGroupId = user.User__c;
      userShare.AccessLevel = 'Read';
      usersShareList.add(userShare);
    }
    if (!usersShareList.isEmpty())
      upsert usersShareList;
  }

  public static void makeUserPrivate(List<Communal_Service_User__c> users) {
    Set<Id> uIds = new Set<Id>();

    for (Communal_Service_User__c user : users) {
      uIds.add(user.User__c);
    }

    List<Communal_Service_User__Share> userShareList = [
      SELECT Id, UserOrGroupId
      FROM Communal_Service_User__Share
      WHERE UserOrGroupId IN :uIds
    ];

    delete userShareList;
  }
}
