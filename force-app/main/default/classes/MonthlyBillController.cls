public with sharing class MonthlyBillController {
  public static Monthly_Bill__c createMonthlyBill(
    Meters_Reading__c metersReading
  ) {
    try {
      City__c res = [
        SELECT
          Id,
          (
            SELECT
              Id,
              Year__c,
              Electricity_Rate_per_kWh__c,
              Gas_Rate__c,
              Water_Rate__c,
              Month__c
            FROM Communal_Rates__r
            WHERE
              Month__c = :metersReading.Month__c
              AND Year__c = :metersReading.Year__c
          ),
          (
            SELECT Id, User__c, Debt__c
            FROM Communal_Service_Users__r
            WHERE User__c = :metersReading.Communal_Service_User__c
          )
        FROM City__c
        LIMIT 1
      ];

      Monthly_Bill__c monthlyBill = new Monthly_Bill__c(
        Communal_Service_User__c = metersReading.Communal_Service_User__c,
        Electricity_Price__c = res.Communal_Rates__r[0]
            .Electricity_Rate_per_kWh__c *
          metersReading.Electricity_Readings__c,
        Gas_Price__c = res.Communal_Rates__r[0].Gas_Rate__c *
          metersReading.Gas_Readings__c,
        Water_Price__c = res.Communal_Rates__r[0].Water_Rate__c *
          metersReading.Water_Readings__c,
        Year__c = metersReading.Year__c,
        Month__c = metersReading.Month__c
      );

      insert monthlyBill;
      return monthlyBill;
    } catch (Exception e) {
      throw new CustomException(e.getMessage());
    }
  }
}
