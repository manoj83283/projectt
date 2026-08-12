import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  // =====================================================
  // BASIC FORMATS
  // =====================================================

  static String formatDate(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  static String formatTime(
    DateTime date,
  ) {
    return DateFormat(
      'hh:mm a',
    ).format(date);
  }

  static String formatDateTime(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(date);
  }

  static String formatShortDate(
    DateTime date,
  ) {
    return DateFormat(
      'dd/MM/yyyy',
    ).format(date);
  }

  static String formatMonthYear(
    DateTime date,
  ) {
    return DateFormat(
      'MMM yyyy',
    ).format(date);
  }

  static String formatDayMonth(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM',
    ).format(date);
  }

  // =====================================================
  // BOOKING FORMATS
  // =====================================================

  static String bookingDate(
    DateTime date,
  ) {
    return DateFormat(
      'EEEE, dd MMM yyyy',
    ).format(date);
  }

  static String bookingDateTime(
    DateTime date,
  ) {
    return DateFormat(
      'EEEE, dd MMM yyyy • hh:mm a',
    ).format(date);
  }

  // =====================================================
  // CHAT FORMAT
  // =====================================================

  static String chatTime(
    DateTime date,
  ) {
    return DateFormat(
      'hh:mm a',
    ).format(date);
  }

  // =====================================================
  // RELATIVE DATE
  // =====================================================

  static String relativeDate(
    DateTime date,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today.difference(target).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference < 7) {
      return '$difference days ago';
    }

    return formatDate(date);
  }

  // =====================================================
  // TIME AGO
  // =====================================================

  static String timeAgo(
    DateTime dateTime,
  ) {
    final difference =
        DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hrs ago';
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
  // NOTIFICATION DATE
  // =====================================================

  static String notificationTime(
    DateTime dateTime,
  ) {
    final now = DateTime.now();
    final difference =
        now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day';
    }

    return formatDate(dateTime);
  }

  // =====================================================
  // DAYS DIFFERENCE
  // =====================================================

  static int daysBetween(
    DateTime start,
    DateTime end,
  ) {
    return end.difference(start).inDays;
  }

  // =====================================================
  // IS TODAY
  // =====================================================

  static bool isToday(
    DateTime date,
  ) {
    final now = DateTime.now();

    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
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

    return yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
  }

  // =====================================================
  // AGE CALCULATION
  // =====================================================

  static int calculateAge(
    DateTime birthDate,
  ) {
    DateTime today = DateTime.now();

    int age =
        today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // =====================================================
  // EVENT COUNTDOWN
  // =====================================================

  static String eventCountdown(
    DateTime eventDate,
  ) {
    final days =
        eventDate.difference(
      DateTime.now(),
    ).inDays;

    if (days < 0) {
      return 'Event Completed';
    }

    if (days == 0) {
      return 'Today';
    }

    if (days == 1) {
      return 'Tomorrow';
    }

    return '$days days left';
  }

  // =====================================================
  // SERVER DATE PARSE
  // =====================================================

  static DateTime? parseDate(
    String? date,
  ) {
    if (date == null || date.isEmpty) {
      return null;
    }

    return DateTime.tryParse(date);
  }

  // =====================================================
  // SERVER DATE FORMAT
  // =====================================================

  static String toApiFormat(
    DateTime date,
  ) {
    return DateFormat(
      'yyyy-MM-dd',
    ).format(date);
  }

  static String toApiDateTime(
    DateTime date,
  ) {
    return DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(date);
  }
}