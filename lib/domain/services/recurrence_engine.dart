import 'dart:math' as math;

import '../../core/utils/date_utils.dart';
import '../enums/enums.dart';
import '../models/recurrence_rule.dart';

/// Service responsible for evaluating and generating task recurrence schedules.
class RecurrenceEngine {
  const RecurrenceEngine();

  /// Default maximum window (in days) for generating occurrences to avoid
  /// unbounded memory usage or infinite loops.
  static const int defaultMaxDaysWindow = 365;

  /// Normalizes any [DateTime] to local midnight (00:00:00.000) for date-only comparison.
  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Evaluates whether the given [rule] is scheduled on [date] (date-only comparison).
  bool isScheduledFor(RecurrenceRule rule, DateTime date) {
    if (rule.isDeleted) return false;

    final target = normalizeDate(date);
    final start = normalizeDate(rule.startDate);

    // Cannot occur before rule start date
    if (target.isBefore(start)) return false;

    // Cannot occur after rule end date if specified
    if (rule.endDate != null) {
      final end = normalizeDate(rule.endDate!);
      if (target.isAfter(end)) return false;
    }

    // Check if the target date matches the recurrence pattern
    if (!_matchesPattern(rule, target, start)) {
      return false;
    }

    // Check maxOccurrences limit if specified
    if (rule.maxOccurrences != null && rule.maxOccurrences! > 0) {
      final count = _countOccurrencesUpTo(rule, target, start);
      if (count > rule.maxOccurrences!) {
        return false;
      }
    }

    return true;
  }

  /// Generates all occurrence dates between [from] and [to] inclusive.
  ///
  /// Safe bounds:
  /// - Clamped to [maxDaysWindow] (default: 365 days) to avoid unbounded generation.
  /// - Respects [rule.startDate] and [rule.endDate].
  /// - Respects [rule.maxOccurrences].
  /// - Date-only comparison normalized to local midnight.
  List<DateTime> generateOccurrences(
    RecurrenceRule rule,
    DateTime from,
    DateTime to, {
    int maxDaysWindow = defaultMaxDaysWindow,
  }) {
    if (rule.isDeleted) return const [];

    final normFrom = normalizeDate(from);
    var normTo = normalizeDate(to);

    if (normFrom.isAfter(normTo)) return const [];

    // Enforce safe upper bound on date range
    if (normTo.difference(normFrom).inDays > maxDaysWindow) {
      normTo = normFrom.add(Duration(days: maxDaysWindow));
    }

    final ruleStart = normalizeDate(rule.startDate);
    if (normTo.isBefore(ruleStart)) return const [];

    final effectiveFrom = normFrom.isBefore(ruleStart) ? ruleStart : normFrom;
    var effectiveTo = normTo;

    if (rule.endDate != null) {
      final ruleEnd = normalizeDate(rule.endDate!);
      if (effectiveFrom.isAfter(ruleEnd)) return const [];
      if (effectiveTo.isAfter(ruleEnd)) {
        effectiveTo = ruleEnd;
      }
    }

    // If maxOccurrences is specified, we must track occurrences from the rule start
    if (rule.maxOccurrences != null && rule.maxOccurrences! > 0) {
      final occurrences = <DateTime>[];
      var count = 0;
      var cur = ruleStart;

      while (!cur.isAfter(effectiveTo)) {
        if (_matchesPattern(rule, cur, ruleStart)) {
          count++;
          if (count > rule.maxOccurrences!) {
            break;
          }
          if (!cur.isBefore(effectiveFrom)) {
            occurrences.add(cur);
          }
        }
        cur = cur.add(const Duration(days: 1));
      }

      return occurrences;
    }

    // No maxOccurrences limit: iterate directly within [effectiveFrom, effectiveTo]
    final occurrences = <DateTime>[];
    var cur = effectiveFrom;

    while (!cur.isAfter(effectiveTo)) {
      if (_matchesPattern(rule, cur, ruleStart)) {
        occurrences.add(cur);
      }
      cur = cur.add(const Duration(days: 1));
    }

    return occurrences;
  }

  /// Finds the next occurrence strictly after the given [after] date.
  ///
  /// Searches up to [maxLookaheadDays] (default 365) days into the future.
  DateTime? nextOccurrence(
    RecurrenceRule rule,
    DateTime after, {
    int maxLookaheadDays = defaultMaxDaysWindow,
  }) {
    if (rule.isDeleted) return null;

    final normAfter = normalizeDate(after);
    final searchStart = normAfter.add(const Duration(days: 1));
    final searchEnd = normAfter.add(Duration(days: maxLookaheadDays));

    final list = generateOccurrences(
      rule,
      searchStart,
      searchEnd,
      maxDaysWindow: maxLookaheadDays,
    );

    return list.isNotEmpty ? list.first : null;
  }

  /// Finds the previous occurrence strictly before the given [before] date.
  DateTime? previousOccurrence(
    RecurrenceRule rule,
    DateTime before, {
    int maxLookbackDays = defaultMaxDaysWindow,
  }) {
    if (rule.isDeleted) return null;

    final normBefore = normalizeDate(before);
    final searchEnd = normBefore.subtract(const Duration(days: 1));
    final searchStart = normBefore.subtract(Duration(days: maxLookbackDays));

    final list = generateOccurrences(
      rule,
      searchStart,
      searchEnd,
      maxDaysWindow: maxLookbackDays,
    );

    return list.isNotEmpty ? list.last : null;
  }

  /// Checks if any occurrences exist between [from] and [to].
  bool hasOccurrencesBetween(RecurrenceRule rule, DateTime from, DateTime to) {
    return generateOccurrences(rule, from, to).isNotEmpty;
  }

  /// Internal pattern matching logic for all recurrence types.
  bool _matchesPattern(RecurrenceRule rule, DateTime target, DateTime start) {
    final diffDays = target.difference(start).inDays;

    switch (rule.type) {
      case RecurrenceType.once:
        return target.isAtSameMomentAs(start);

      case RecurrenceType.daily:
        final step = (rule.intervalDays != null && rule.intervalDays! > 0)
            ? rule.intervalDays!
            : 1;
        return diffDays % step == 0;

      case RecurrenceType.weekdays:
        return target.weekday >= DateTime.monday &&
            target.weekday <= DateTime.friday;

      case RecurrenceType.everyOtherDay:
        return diffDays % 2 == 0;

      case RecurrenceType.everyNDays:
        final step = (rule.intervalDays != null && rule.intervalDays! > 0)
            ? rule.intervalDays!
            : 1;
        return diffDays % step == 0;

      case RecurrenceType.weekly:
        final validDays =
            (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty)
            ? rule.daysOfWeek!
            : [start.weekday];

        if (!validDays.contains(target.weekday)) return false;

        var intervalWeeks = 1;
        if (rule.intervalDays != null && rule.intervalDays! > 0) {
          if (rule.intervalDays! % 7 == 0) {
            intervalWeeks = rule.intervalDays! ~/ 7;
          } else if (rule.intervalDays! >= 7) {
            intervalWeeks = rule.intervalDays! ~/ 7;
          } else {
            intervalWeeks = rule.intervalDays!;
          }
        }
        if (intervalWeeks < 1) intervalWeeks = 1;

        final startMonday = start.subtract(Duration(days: start.weekday - 1));
        final targetMonday = target.subtract(Duration(days: target.weekday - 1));
        final weeksDiff = targetMonday.difference(startMonday).inDays ~/ 7;

        if (weeksDiff < 0 || weeksDiff % intervalWeeks != 0) return false;
        return true;

      case RecurrenceType.monthly:
        final step = (rule.intervalMonths != null && rule.intervalMonths! > 0)
            ? rule.intervalMonths!
            : 1;
        final monthsDiff =
            (target.year - start.year) * 12 + target.month - start.month;
        if (monthsDiff < 0 || monthsDiff % step != 0) return false;

        // Handle shorter months by capping to the last day of the target month
        final maxDaysInTargetMonth = AppDateUtils.daysInMonth(
          target.year,
          target.month,
        );
        final expectedDay = math.min(start.day, maxDaysInTargetMonth);
        return target.day == expectedDay;

      case RecurrenceType.everyNMonths:
        final step = (rule.intervalMonths != null && rule.intervalMonths! > 0)
            ? rule.intervalMonths!
            : 1;
        final monthsDiff =
            (target.year - start.year) * 12 + target.month - start.month;
        if (monthsDiff < 0 || monthsDiff % step != 0) return false;

        final maxDaysInTargetMonth = AppDateUtils.daysInMonth(
          target.year,
          target.month,
        );
        final expectedDay = math.min(start.day, maxDaysInTargetMonth);
        return target.day == expectedDay;

      case RecurrenceType.custom:
        if (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty) {
          if (!rule.daysOfWeek!.contains(target.weekday)) return false;
        }
        if (rule.intervalDays != null && rule.intervalDays! > 0) {
          if (diffDays % rule.intervalDays! != 0) return false;
        }
        if (rule.intervalMonths != null && rule.intervalMonths! > 0) {
          final monthsDiff =
              (target.year - start.year) * 12 + target.month - start.month;
          if (monthsDiff < 0 || monthsDiff % rule.intervalMonths! != 0) {
            return false;
          }
          final maxDaysInTargetMonth = AppDateUtils.daysInMonth(
            target.year,
            target.month,
          );
          final expectedDay = math.min(start.day, maxDaysInTargetMonth);
          if (target.day != expectedDay) return false;
        }
        return true;
    }
  }

  /// Counts the total occurrences from [start] up to [target] inclusive.
  int _countOccurrencesUpTo(
    RecurrenceRule rule,
    DateTime target,
    DateTime start,
  ) {
    var count = 0;
    var cur = start;
    final maxOccurrences = rule.maxOccurrences ?? 0;

    while (!cur.isAfter(target)) {
      if (_matchesPattern(rule, cur, start)) {
        count++;
        // Early break if we have already exceeded maxOccurrences
        if (maxOccurrences > 0 && count > maxOccurrences) {
          return count;
        }
      }
      cur = cur.add(const Duration(days: 1));
    }

    return count;
  }
}
