// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:timezone/timezone.dart' as tz;

class Util {
  /// Returns the current time in the estern timezone, or of
  /// a time specified.
  static DateTime getEstDateTime({DateTime? dateTime, bool dateOnly = false}) {
    dateTime = (dateTime ?? DateTime.now()).toUtc();
    DateTime offsetTime = dateTime.add(_getEstOffset());
    return DateTime(
        offsetTime.year,
        offsetTime.month,
        offsetTime.day,
        !dateOnly ? offsetTime.hour : 0,
        !dateOnly ? offsetTime.minute : 0,
        !dateOnly ? offsetTime.minute : 0,
        !dateOnly ? offsetTime.microsecond : 0,
        !dateOnly ? offsetTime.millisecond : 0);
  }

  /// Gets the EST offset from UTC
  static Duration _getEstOffset() {
    tz.Location estTimezone = tz.getLocation('America/New_York');
    tz.TZDateTime nowEst = tz.TZDateTime.now(estTimezone);
    return Duration(hours: nowEst.timeZoneOffset.inHours);
  }

  /// Converts a [dateTime] to the expected NASA request format.
  static String toRequestDateFormat(DateTime dateTime) {
    return "${dateTime.year.toString()}-${dateTime.month.toString()}-${dateTime.day.toString()}";
  }
}
