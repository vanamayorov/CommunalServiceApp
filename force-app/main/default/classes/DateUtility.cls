public with sharing class DateUtility {
  public static String getYear() {
    return String.valueOf(Date.today().year());
  }

  public static String getMonth() {
    Integer month = Date.today().month();
    Map<Integer, String> monthMap = new Map<Integer, String>{
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
    return monthMap.get(month);
  }
}
