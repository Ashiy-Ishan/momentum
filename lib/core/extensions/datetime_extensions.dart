import '../utils/date_utils.dart';

extension DateTimeX on DateTime {
  bool get isToday => AppDateUtils.isToday(this);
  bool get isTomorrow =>
      AppDateUtils.isSameDay(this, DateTime.now().add(const Duration(days: 1)));
  bool get isYesterday => AppDateUtils.isSameDay(
    this,
    DateTime.now().subtract(const Duration(days: 1)),
  );
  bool get isPast => AppDateUtils.isPast(this);
  bool get isFuture => AppDateUtils.isFuture(this);

  DateTime get startOfDay => AppDateUtils.startOfDay(this);
  DateTime get endOfDay => AppDateUtils.endOfDay(this);

  String get formatted => AppDateUtils.formatDate(this);
  String get relativeFormatted => AppDateUtils.formatRelativeDate(this);
  String get timeFormatted => AppDateUtils.formatTime(this);
  String get dateTimeFormatted => AppDateUtils.formatDateTime(this);

  int get weekOfYear => AppDateUtils.weekOfYear(this);
}
