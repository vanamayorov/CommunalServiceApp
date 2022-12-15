public with sharing class LoginController {
  @AuraEnabled
  public static Map<String, String> login(String payload) {
    try {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload
      );
      String login = (String) payloadMap.get('login');
      String password = (String) payloadMap.get('password');
      String userId = (String) payloadMap.get('userId');

      Communal_Service_User__c communalUser;

      for (Communal_Service_User__c user : [
        SELECT Id, User__c, Login__c, Password__c
        FROM Communal_Service_User__c
      ]) {
        if (
          user.Login__c == login &&
          EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(password))
          ) == user.Password__c
        ) {
          communalUser = user;
        }
      }

      if (communalUser == null) {
        throw new CustomException('Incorrect login or password, try again.');
      }

      AuthorizedUserPermissionSetController.createAssignment(userId);
      return new Map<String, String>{ 'status' => 'Successfully logged in' };
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
