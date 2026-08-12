import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  // =====================================================
  // FORMATTING
  // =====================================================

  String get formattedDate {
    return DateFormat(
      'dd MMM yyyy',
    ).format(this);
  }

  String get formattedTime {
    return DateFormat(
      'hh:mm a',
    ).format(this);
  }

  String get formattedDateTime {
    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(this);
  }

  String get shortDate {
    return DateFormat(
      'dd/MM/yyyy',
    ).format(this);
  }

  String get monthYear {
    return DateFormat(
      'MMM yyyy',
    ).format(this);
  }

  String get dayMonth {
    return DateFormat(
      'dd MMM',
    ).format(this);
  }

  String get dayName {
    return DateFormat(
      'EEEE',
    ).format(this);
  }

  // =====================================================
  // DATE CHECKS
  // =====================================================

  bool get isToday {
    final now = DateTime.now();

    return year == now.year &&
        month == now.month &&
        day == now.day;
  }

  bool get isYesterday {
    final yesterday =
        DateTime.now().subtract(
      const Duration(days: 1),
    );

    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow =
        DateTime.now().add(
      const Duration(days: 1),
    );

    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isPast {
    return isBefore(DateTime.now());
  }

  bool get isFuture {
    return isAfter(DateTime.now());
  }

  // =====================================================
  // RELATIVE DATE
  // =====================================================

  String get relativeDate {
    if (isToday) {
      return 'Today';
    }

    if (isYesterday) {
      return 'Yesterday';
    }

    if (isTomorrow) {
      return 'Tomorrow';
    }

    final difference =
        DateTime.now().difference(this);

    if (difference.inDays < 7 &&
        difference.inDays > 0) {
      return '${difference.inDays} days ago';
    }

    return formattedDate;
  }

  // =====================================================
  // TIME AGO
  // =====================================================

  String get timeAgo {
    final difference =
        DateTime.now().difference(this);

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
  // EVENT COUNTDOWN
  // =====================================================

  String get countdown {
    final days =
        difference(DateTime.now()).inDays;

    if (days < 0) {
      return 'Completed';
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
  // API FORMAT
  // =====================================================

  String get apiDate {
    return DateFormat(
      'yyyy-MM-dd',
    ).format(this);
  }

  String get apiDateTime {
    return DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(this);
  }

  // =====================================================
  // BOOKING FORMAT
  // =====================================================

  String get bookingDate {
    return DateFormat(
      'EEEE, dd MMM yyyy',
    ).format(this);
  }

  String get bookingDateTime {
    return DateFormat(
      'EEEE, dd MMM yyyy • hh:mm a',
    ).format(this);
  }

  // =====================================================
  // AGE
  // =====================================================

  int get age {
    final today = DateTime.now();

    int calculatedAge =
        today.year - year;

    if (today.month < month ||
        (today.month == month &&
            today.day < day)) {
      calculatedAge--;
    }

    return calculatedAge;
  }

  // =====================================================
  // DATE DIFFERENCE
  // =====================================================

  int daysUntil(DateTime date) {
    return date
        .difference(this)
        .inDays;
  }

  int daysFrom(DateTime date) {
    return difference(date).inDays;
  }

  // =====================================================
  // START / END OF DAY
  // =====================================================

  DateTime get startOfDay {
    return DateTime(
      year,
      month,
      day,
    );
  }

  DateTime get endOfDay {
    return DateTime(
      year,
      month,
      day,
      23,
      59,
      59,
      999,
    );
  }

  // =====================================================
  // DATE COPY
  // =====================================================

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
    );
  }
}