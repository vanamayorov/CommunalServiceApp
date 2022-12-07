public with sharing class RegionController {
  @AuraEnabled(cacheable=true)
  public static List<Region__c> getRegions() {
    try {
      return [
        SELECT
          Id,
          Name,
          (SELECT Id FROM Region_Managers__r LIMIT 1),
          (SELECT Id, Name FROM Cities__r)
        FROM Region__c
      ];
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
