public with sharing class CommunalServiceUserTriggerHandler {
  public static void makeUserPublic(List<Communal_Service_User__c> users) {
    List<Communal_Service_User__Share> usersShareList = new List<Communal_Service_User__Share>();
    List<Communal_Service_User__Share> usersShareListToDelete = new List<Communal_Service_User__Share>();
    Set<Id> usersIds = new Set<Id>();

    for (Communal_Service_User__c user : users) {
      usersIds.add(user.Id);
    }

    Map<Id, Communal_Service_User__Share> existingUsersShareList = new Map<Id, Communal_Service_User__Share>();

    for (Communal_Service_User__Share rule : [
      SELECT Id, ParentId, RowCause
      FROM Communal_Service_User__Share
      WHERE ParentId IN :usersIds AND RowCause = 'Manual'
    ]) {
      existingUsersShareList.put(rule.ParentId, rule);
    }

    if (!existingUsersShareList.keySet().isEmpty()) {
      for (Communal_Service_User__c user : [
        SELECT Id, Region_Manager__c, Region_Manager__r.User__c
        FROM Communal_Service_User__c
        WHERE Id IN :usersIds AND Region_Manager__c != NULL
      ]) {
        if (existingUsersShareList.get(user.Id) != null) {
          usersShareListToDelete.add(existingUsersShareList.get(user.Id));
        }
      }
    }

    if (!usersShareListToDelete.isEmpty())
      delete usersShareListToDelete;

    for (Communal_Service_User__c user : [
      SELECT Id, Region_Manager__c, Region_Manager__r.User__c
      FROM Communal_Service_User__c
      WHERE Id IN :usersIds AND Region_Manager__c != NULL
    ]) {
      Communal_Service_User__Share userShare = new Communal_Service_User__Share();
      userShare.ParentId = user.Id;
      userShare.UserOrGroupId = user.Region_Manager__r.User__c;
      userShare.AccessLevel = 'Read';
      usersShareList.add(userShare);
    }

    if (!usersShareList.isEmpty())
      upsert usersShareList;
  }

  public static void makeUserPrivate(List<Communal_Service_User__c> users) {
    Set<Id> uIds = new Set<Id>();
    Set<Id> regManIds = new Set<Id>();

    for (Communal_Service_User__c user : users) {
      uIds.add(user.Id);
    }

    for (Communal_Service_User__c user : [
      SELECT Id, Region_Manager__r.User__c
      FROM Communal_Service_User__c
      WHERE Id IN :uIds
    ]) {
      regManIds.add(user.Region_Manager__r.User__c);
    }

    List<Communal_Service_User__Share> userShareList = [
      SELECT Id, UserOrGroupId
      FROM Communal_Service_User__Share
      WHERE UserOrGroupId IN :regManIds
    ];

    if (!userShareList.isEmpty()) {
      delete userShareList;
    }
  }

  public static void checkIfUserOwnerHasOtherUsers(
    List<Communal_Service_User__c> communalUsers
  ) {
    Set<Id> users = new Set<Id>();
    for (Communal_Service_User__c comUser : communalUsers) {
      users.add(comUser.User__c);
    }

    Map<Id, Communal_Service_User__c> comUsersWithSetUsers = new Map<Id, Communal_Service_User__c>();

    for (Communal_Service_User__c comUser : [
      SELECT Id, User__c
      FROM Communal_Service_User__c
      WHERE User__c IN :users
    ]) {
      comUsersWithSetUsers.put(comUser.User__c, comUser);
    }

    if (comUsersWithSetUsers.keySet().isEmpty())
      return;

    for (Communal_Service_User__c comUser : communalUsers) {
      if (
        comUsersWithSetUsers.get(comUser.User__c) != null &&
        (comUser.Id == null ||
        comUsersWithSetUsers.get(comUser.User__c).Id != comUser.Id)
      ) {
        comUser.addError(
          'This user is already set in another communal service user record.'
        );
      }
    }
  }
}
