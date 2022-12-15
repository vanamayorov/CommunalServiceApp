public with sharing class RegistrationController {
  @AuraEnabled
  public static Map<String, String> register(String payload) {
    try {
      Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(
        payload
      );
      String login = (String) payloadMap.get('login');
      String password = (String) payloadMap.get('password');
      String regionId = (String) payloadMap.get('regionId');
      String cityId = (String) payloadMap.get('cityId');
      String managerId = (String) payloadMap.get('managerId');
      String userId = (String) payloadMap.get('userId');

      Communal_Service_User__c communalUser = new Communal_Service_User__c(
        Login__c = login,
        Password__c = EncodingUtil.convertToHex(
          Crypto.generateDigest('SHA-256', Blob.valueOf(password))
        ),
        Region__c = regionId,
        City__c = cityId,
        User__c = userId,
        Region_Manager__c = managerId
      );

      insert communalUser;

      AuthorizedUserPermissionSetController.createAssignment(userId);
      return new Map<String, String>{ 'status' => 'Successfully registered' };
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
