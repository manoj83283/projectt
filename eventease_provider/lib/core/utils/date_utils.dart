import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  // =====================================================
  // DATE FORMATS
  // =====================================================

  static const String ddMMyyyy =
      'dd-MM-yyyy';

  static const String yyyyMMdd =
      'yyyy-MM-dd';

  static const String ddMMMyyyy =
      'dd MMM yyyy';

  static const String ddMMMyyyyHHmm =
      'dd MMM yyyy, hh:mm a';

  static const String hhmmA =
      'hh:mm a';

  static const String serverFormat =
      'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // =====================================================
  // FORMAT DATE
  // =====================================================

  static String format(
    DateTime date, {
    String pattern = ddMMMyyyy,
  }) {
    return DateFormat(pattern).format(date);
  }

  // =====================================================
  // FORMAT DATE TIME
  // =====================================================

  static String formatDateTime(
    DateTime date,
  ) {
    return DateFormat(
      ddMMMyyyyHHmm,
    ).format(date);
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  static String formatTime(
    DateTime date,
  ) {
    return DateFormat(
      hhmmA,
    ).format(date);
  }

  // =====================================================
  // PARSE STRING DATE
  // =====================================================

  static DateTime? parse(
    String? value, {
    String pattern = yyyyMMdd,
  }) {
    try {
      if (value == null ||
          value.isEmpty) {
        return null;
      }

      return DateFormat(pattern)
          .parse(value);
    } catch (_) {
      return null;
    }
  }

  // =====================================================
  // SERVER DATE PARSER
  // =====================================================

  static DateTime? parseServerDate(
    String? value,
  ) {
    try {
      if (value == null ||
          value.isEmpty) {
        return null;
      }

      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // =====================================================
  // TODAY
  // =====================================================

  static DateTime get today {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  // =====================================================
  // START OF DAY
  // =====================================================

  static DateTime startOfDay(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // =====================================================
  // END OF DAY
  // =====================================================

  static DateTime endOfDay(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
      999,
    );
  }

  // =====================================================
  // START OF MONTH
  // =====================================================

  static DateTime startOfMonth(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month,
      1,
    );
  }

  // =====================================================
  // END OF MONTH
  // =====================================================

  static DateTime endOfMonth(
    DateTime date,
  ) {
    return DateTime(
      date.year,
      date.month + 1,
      0,
      23,
      59,
      59,
    );
  }

  // =====================================================
  // DAYS BETWEEN
  // =====================================================

  static int daysBetween(
    DateTime start,
    DateTime end,
  ) {
    return end
        .difference(start)
        .inDays;
  }

  // =====================================================
  // HOURS BETWEEN
  // =====================================================

  static int hoursBetween(
    DateTime start,
    DateTime end,
  ) {
    return end
        .difference(start)
        .inHours;
  }

  // =====================================================
  // MINUTES BETWEEN
  // =====================================================

  static int minutesBetween(
    DateTime start,
    DateTime end,
  ) {
    return end
        .difference(start)
        .inMinutes;
  }

  // =====================================================
  // IS TODAY
  // =====================================================

  static bool isToday(
    DateTime date,
  ) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // =====================================================
  // IS YESTERDAY
  // =====================================================

  static bool isYesterday(
    DateTime date,
  ) {
    final yesterday =
        DateTime.now().subtract(
      const Duration(days: 1),
    );

    return date.year ==
            yesterday.year &&
        date.month ==
            yesterday.month &&
        date.day ==
            yesterday.day;
  }

  // =====================================================
  // IS SAME DAY
  // =====================================================

  static bool isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year ==
            second.year &&
        first.month ==
            second.month &&
        first.day ==
            second.day;
  }

  // =====================================================
  // RELATIVE TIME
  // =====================================================

  static String timeAgo(
    DateTime date,
  ) {
    final difference =
        DateTime.now()
            .difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }

    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    }

    return '${(difference.inDays / 365).floor()} years ago';
  }

  // =====================================================
  // CHAT TIMESTAMP
  // =====================================================

  static String chatTime(
    DateTime date,
  ) {
    if (isToday(date)) {
      return DateFormat(
        hhmmA,
      ).format(date);
    }

    if (isYesterday(date)) {
      return 'Yesterday';
    }

    return DateFormat(
      'dd/MM/yy',
    ).format(date);
  }

  // =====================================================
  // BOOKING DATE RANGE
  // =====================================================

  static String bookingDateRange(
    DateTime start,
    DateTime end,
  ) {
    return '${format(start)} - ${format(end)}';
  }

  // =====================================================
  // AGE FROM DOB
  // =====================================================

  static int calculateAge(
    DateTime dob,
  ) {
    final today = DateTime.now();

    int age =
        today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month &&
            today.day < dob.day)) {
      age--;
    }

    return age;
  }

  // =====================================================
  // CURRENT TIMESTAMP
  // =====================================================

  static String currentTimestamp() {
    return DateTime.now()
        .millisecondsSinceEpoch
        .toString();
  }

  // =====================================================
  // API DATE
  // =====================================================

  static String toApiDate(
    DateTime date,
  ) {
    return DateFormat(
      yyyyMMdd,
    ).format(date);
  }

  // =====================================================
  // API DATE TIME
  // =====================================================

  static String toApiDateTime(
    DateTime date,
  ) {
    return date.toIso8601String();
  }
}