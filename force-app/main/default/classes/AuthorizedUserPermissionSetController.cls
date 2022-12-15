public with sharing class AuthorizedUserPermissionSetController {
  @future
  public static void createAssignment(String userId) {
    PermissionSet permissionSet = [
      SELECT Id, Name
      FROM PermissionSet
      WHERE Name = 'Authorized_User_Permission'
      LIMIT 1
    ];

    PermissionSetAssignment assignment = new PermissionSetAssignment();
    assignment.AssigneeId = userId;
    assignment.PermissionSetId = permissionSet.Id;
    insert assignment;
  }
}
