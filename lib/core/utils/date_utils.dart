import 'package:intl/intl.dart';

abstract class AppDateUtils {
  static DateTime startOfDay(DateTime date) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999)
        : DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date, {int startDay = DateTime.monday}) {
    final diff = (date.weekday - startDay + 7) % 7;
    final start = date.subtract(Duration(days: diff));
    return startOfDay(start);
  }

  static DateTime endOfWeek(DateTime date, {int startDay = DateTime.monday}) {
    final start = startOfWeek(date, startDay: startDay);
    final end = start.add(const Duration(days: 6));
    return endOfDay(end);
  }

  static DateTime startOfMonth(DateTime date) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, 1)
        : DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    final days = daysInMonth(date.year, date.month);
    return date.isUtc
        ? DateTime.utc(date.year, date.month, days, 23, 59, 59, 999)
        : DateTime(date.year, date.month, days, 23, 59, 59, 999);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isPast(DateTime date) {
    return startOfDay(date).isBefore(startOfDay(DateTime.now()));
  }

  static bool isFuture(DateTime date) {
    return startOfDay(date).isAfter(startOfDay(DateTime.now()));
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(date, yesterday)) {
      return 'Yesterday';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (isSameDay(date, tomorrow)) {
      return 'Tomorrow';
    }
    return formatDate(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  static String formatDuration(Duration duration) {
    final d = duration.abs();
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      final seconds = d.inSeconds;
      if (seconds > 0) {
        return '${seconds}s';
      }
      return '0m';
    }
  }

  static String formatDurationTimer(
    Duration duration, {
    bool alwaysIncludeHours = false,
  }) {
    final d = duration.abs();
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0 || alwaysIncludeHours) {
      return '$hours:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }

  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final s = startOfDay(start);
    final e = startOfDay(end);
    if (s.isAfter(e)) return [];

    final result = <DateTime>[];
    var current = s;
    while (!current.isAfter(e)) {
      result.add(current);
      current = s.isUtc
          ? DateTime.utc(current.year, current.month, current.day + 1)
          : DateTime(current.year, current.month, current.day + 1);
    }
    return result;
  }

  static int weekOfYear(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    final thursday = d.add(Duration(days: 4 - d.weekday));
    final firstDayOfYear = DateTime.utc(thursday.year, 1, 1);
    final firstThursday = firstDayOfYear.add(
      Duration(days: (4 - firstDayOfYear.weekday + 7) % 7),
    );
    return (thursday.difference(firstThursday).inDays / 7).floor() + 1;
  }
}
