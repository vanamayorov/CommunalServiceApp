@isTest
private class DateUtilityTest {
  private static final Map<Integer, String> monthMap = new Map<Integer, String>{
    1 => 'January',
    2 => 'February',
    3 => 'March',
    4 => 'April',
    5 => 'May',
    6 => 'June',
    7 => 'July',
    8 => 'August',
    9 => 'September',
    10 => 'October',
    11 => 'November',
    12 => 'December'
  };

  @isTest
  static void getYearTestPositive() {
    String expectedYear = String.valueOf(Date.today().year());
    String actualYear = DateUtility.getYear();
    System.assertEquals(expectedYear, actualYear);
  }

  @isTest
  static void getYearTestNegative() {
    String expectedYear = '2012';
    String actualYear = DateUtility.getYear();
    System.assertNotEquals(expectedYear, actualYear);
  }

  @isTest
  static void getMonthTestPositive() {
    Integer month = Date.today().month();
    String expectedMonth = monthMap.get(month);
    String actualMonth = DateUtility.getMonth();
    System.assertEquals(expectedMonth, actualMonth);
  }

  @isTest
  static void getMonthTestNegative() {
    String expectedMonth = 'August';
    String actualMonth = DateUtility.getMonth();
    System.assertNotEquals(expectedMonth, actualMonth);
  }
}
