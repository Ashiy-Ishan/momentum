import 'package:flutter/material.dart';

enum TaskStatus {
  pending,
  doing,
  done,
  skipped,
  cancelled;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.doing:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.skipped:
        return 'Skipped';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.pending:
        return Icons.hourglass_empty_rounded;
      case TaskStatus.doing:
        return Icons.play_circle_outline_rounded;
      case TaskStatus.done:
        return Icons.check_circle_outline_rounded;
      case TaskStatus.skipped:
        return Icons.skip_next_rounded;
      case TaskStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFFC28D4E);
      case TaskStatus.doing:
        return const Color(0xFF5B82A6);
      case TaskStatus.done:
        return const Color(0xFF4E9B78);
      case TaskStatus.skipped:
        return const Color(0xFF64748B);
      case TaskStatus.cancelled:
        return const Color(0xFFB85454);
    }
  }

  String get iconName {
    switch (this) {
      case TaskStatus.pending:
        return 'hourglass_empty';
      case TaskStatus.doing:
        return 'play_circle_outline';
      case TaskStatus.done:
        return 'check_circle_outline';
      case TaskStatus.skipped:
        return 'skip_next';
      case TaskStatus.cancelled:
        return 'cancel';
    }
  }

  String get colorHex {
    switch (this) {
      case TaskStatus.pending:
        return '#C28D4E';
      case TaskStatus.doing:
        return '#5B82A6';
      case TaskStatus.done:
        return '#4E9B78';
      case TaskStatus.skipped:
        return '#64748B';
      case TaskStatus.cancelled:
        return '#B85454';
    }
  }

  factory TaskStatus.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'completed' || normalized == 'done') {
      return TaskStatus.done;
    }
    return TaskStatus.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => TaskStatus.pending,
    );
  }

  static TaskStatus? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized == 'completed' || normalized == 'done') {
      return TaskStatus.done;
    }
    for (final status in TaskStatus.values) {
      if (status.name.toLowerCase() == normalized ||
          status.displayName.toLowerCase() == normalized) {
        return status;
      }
    }
    return null;
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  int get level => index;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF64748B);
      case TaskPriority.medium:
        return const Color(0xFF5B82A6);
      case TaskPriority.high:
        return const Color(0xFFC28D4E);
      case TaskPriority.urgent:
        return const Color(0xFFB85454);
    }
  }

  String get iconName {
    switch (this) {
      case TaskPriority.low:
        return 'arrow_downward';
      case TaskPriority.medium:
        return 'remove';
      case TaskPriority.high:
        return 'arrow_upward';
      case TaskPriority.urgent:
        return 'priority_high';
    }
  }

  String get colorHex {
    switch (this) {
      case TaskPriority.low:
        return '#64748B';
      case TaskPriority.medium:
        return '#5B82A6';
      case TaskPriority.high:
        return '#C28D4E';
      case TaskPriority.urgent:
        return '#B85454';
    }
  }

  factory TaskPriority.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return TaskPriority.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => TaskPriority.medium,
    );
  }

  static TaskPriority? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final priority in TaskPriority.values) {
      if (priority.name.toLowerCase() == normalized ||
          priority.displayName.toLowerCase() == normalized) {
        return priority;
      }
    }
    return null;
  }
}

enum RecurrenceType {
  once,
  daily,
  weekdays,
  everyOtherDay,
  everyNDays,
  weekly,
  monthly,
  everyNMonths,
  custom;

  String get displayName {
    switch (this) {
      case RecurrenceType.once:
        return 'Once';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekdays:
        return 'Weekdays';
      case RecurrenceType.everyOtherDay:
        return 'Every Other Day';
      case RecurrenceType.everyNDays:
        return 'Every N Days';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.everyNMonths:
        return 'Every N Months';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  factory RecurrenceType.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return RecurrenceType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => RecurrenceType.once,
    );
  }

  static RecurrenceType? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in RecurrenceType.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum KpiType {
  count,
  rate,
  time;

  String get displayName {
    switch (this) {
      case KpiType.count:
        return 'Count';
      case KpiType.rate:
        return 'Rate';
      case KpiType.time:
        return 'Time';
    }
  }

  factory KpiType.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return KpiType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => KpiType.count,
    );
  }

  static KpiType? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in KpiType.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum KpiPeriod {
  daily,
  weekly,
  monthly,
  custom;

  String get displayName {
    switch (this) {
      case KpiPeriod.daily:
        return 'Daily';
      case KpiPeriod.weekly:
        return 'Weekly';
      case KpiPeriod.monthly:
        return 'Monthly';
      case KpiPeriod.custom:
        return 'Custom';
    }
  }

  factory KpiPeriod.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return KpiPeriod.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => KpiPeriod.daily,
    );
  }

  static KpiPeriod? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in KpiPeriod.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum TimerSessionStatus {
  running,
  paused,
  completed;

  String get displayName {
    switch (this) {
      case TimerSessionStatus.running:
        return 'Running';
      case TimerSessionStatus.paused:
        return 'Paused';
      case TimerSessionStatus.completed:
        return 'Completed';
    }
  }

  IconData get icon {
    switch (this) {
      case TimerSessionStatus.running:
        return Icons.play_arrow_rounded;
      case TimerSessionStatus.paused:
        return Icons.pause_rounded;
      case TimerSessionStatus.completed:
        return Icons.stop_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TimerSessionStatus.running:
        return const Color(0xFF4CAF50);
      case TimerSessionStatus.paused:
        return const Color(0xFFFF9800);
      case TimerSessionStatus.completed:
        return const Color(0xFF2196F3);
    }
  }

  factory TimerSessionStatus.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return TimerSessionStatus.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => TimerSessionStatus.running,
    );
  }

  static TimerSessionStatus? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in TimerSessionStatus.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum SyncOperation {
  insert,
  update,
  delete;

  String get displayName {
    switch (this) {
      case SyncOperation.insert:
        return 'Insert';
      case SyncOperation.update:
        return 'Update';
      case SyncOperation.delete:
        return 'Delete';
    }
  }

  factory SyncOperation.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return SyncOperation.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => SyncOperation.insert,
    );
  }

  static SyncOperation? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in SyncOperation.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum SyncStatus {
  pending,
  processing,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.processing:
        return 'Processing';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
    }
  }

  factory SyncStatus.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return SyncStatus.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => SyncStatus.pending,
    );
  }

  static SyncStatus? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in SyncStatus.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum AttachmentSyncStatus {
  pending,
  uploaded,
  failed;

  String get displayName {
    switch (this) {
      case AttachmentSyncStatus.pending:
        return 'Pending';
      case AttachmentSyncStatus.uploaded:
        return 'Uploaded';
      case AttachmentSyncStatus.failed:
        return 'Failed';
    }
  }

  factory AttachmentSyncStatus.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return AttachmentSyncStatus.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => AttachmentSyncStatus.pending,
    );
  }

  static AttachmentSyncStatus? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in AttachmentSyncStatus.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}

enum ThemePreference {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case ThemePreference.light:
        return 'Light';
      case ThemePreference.dark:
        return 'Dark';
      case ThemePreference.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemePreference.light:
        return Icons.light_mode_outlined;
      case ThemePreference.dark:
        return Icons.dark_mode_outlined;
      case ThemePreference.system:
        return Icons.brightness_auto_outlined;
    }
  }

  factory ThemePreference.fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return ThemePreference.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.displayName.toLowerCase() == normalized,
      orElse: () => ThemePreference.system,
    );
  }

  static ThemePreference? tryFromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    for (final item in ThemePreference.values) {
      if (item.name.toLowerCase() == normalized ||
          item.displayName.toLowerCase() == normalized) {
        return item;
      }
    }
    return null;
  }
}
