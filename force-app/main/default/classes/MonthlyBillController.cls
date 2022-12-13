public with sharing class MonthlyBillController {
  public static Monthly_Bill__c createMonthlyBill(
    Meters_Reading__c metersReading
  ) {
    try {
      Communal_Service_User__c user = [
        SELECT Id, City__c
        FROM Communal_Service_User__c
        WHERE Id = :metersReading.Communal_Service_User__c
        LIMIT 1
      ];

      Communal_Rates__c communalRate = [
        SELECT
          Id,
          City__c,
          Electricity_Rate_per_kWh__c,
          Gas_Rate__c,
          Water_Rate__c,
          Year__c,
          Month__c
        FROM Communal_Rates__c
        WHERE
          City__c = :user.City__c
          AND Month__c = :metersReading.Month__c
          AND Year__c = :metersReading.Year__c
        LIMIT 1
      ];

      Monthly_Bill__c monthlyBill = new Monthly_Bill__c(
        Communal_Service_User__c = metersReading.Communal_Service_User__c,
        Electricity_Price__c = communalRate.Electricity_Rate_per_kWh__c *
          metersReading.Electricity_Readings__c,
        Gas_Price__c = communalRate.Gas_Rate__c * metersReading.Gas_Readings__c,
        Water_Price__c = communalRate.Water_Rate__c *
          metersReading.Water_Readings__c,
        Year__c = metersReading.Year__c,
        Month__c = metersReading.Month__c,
        Created_Date__c = Date.today()
      );
      insert monthlyBill;
      return monthlyBill;
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
