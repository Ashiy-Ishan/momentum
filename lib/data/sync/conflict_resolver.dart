import 'package:flutter_riverpod/flutter_riverpod.dart';

final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  return const ConflictResolver();
});

enum ConflictResolution {
  localWins,

  remoteWins,

  preserveBoth,
}

class ConflictResolutionResult {
  final ConflictResolution resolution;
  final String reason;
  final Map<String, dynamic> winningData;

  const ConflictResolutionResult({
    required this.resolution,
    required this.reason,
    required this.winningData,
  });

  bool get isLocalWinner => resolution == ConflictResolution.localWins;
  bool get isRemoteWinner => resolution == ConflictResolution.remoteWins;
  bool get shouldPreserveBoth => resolution == ConflictResolution.preserveBoth;

  @override
  String toString() =>
      'ConflictResolutionResult(resolution: $resolution, reason: $reason)';
}

class ConflictResolver {
  const ConflictResolver();

  static const Set<String> appendOnlyTables = {
    'completion_events',
    'timer_sessions',
  };

  bool isAppendOnly(String tableName) {
    final normalized = _normalizeTableName(tableName);
    return appendOnlyTables.contains(normalized);
  }

  ConflictResolutionResult resolve({
    required String tableName,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
  }) {
    final normalizedTable = _normalizeTableName(tableName);

    if (isAppendOnly(normalizedTable)) {
      return ConflictResolutionResult(
        resolution: ConflictResolution.preserveBoth,
        reason:
            'Append-only policy applies to "$normalizedTable": both local and remote records are preserved.',
        winningData: remoteData,
      );
    }

    final localDeleted = _parseBool(
      localData['is_deleted'] ?? localData['isDeleted'],
    );
    final remoteDeleted = _parseBool(
      remoteData['is_deleted'] ?? remoteData['isDeleted'],
    );

    if (remoteDeleted) {
      return ConflictResolutionResult(
        resolution: ConflictResolution.remoteWins,
        reason:
            'Server-wins deletion policy: Remote record is marked deleted on server.',
        winningData: remoteData,
      );
    }

    if (localDeleted && !remoteDeleted) {
      return ConflictResolutionResult(
        resolution: ConflictResolution.remoteWins,
        reason:
            'Server-wins deletion policy: Remote active record takes precedence over local deletion.',
        winningData: remoteData,
      );
    }

    final localVersion = _tryParseInt(
      localData['version'] ?? localData['Version'],
    );
    final remoteVersion = _tryParseInt(
      remoteData['version'] ?? remoteData['Version'],
    );

    if (localVersion != null && remoteVersion != null && localVersion != remoteVersion) {
      if (localVersion > remoteVersion) {
        return ConflictResolutionResult(
          resolution: ConflictResolution.localWins,
          reason:
              'Last-write-wins: Local version ($localVersion) is higher than remote ($remoteVersion).',
          winningData: localData,
        );
      } else {
        return ConflictResolutionResult(
          resolution: ConflictResolution.remoteWins,
          reason:
              'Last-write-wins: Remote version ($remoteVersion) is higher than local ($localVersion).',
          winningData: remoteData,
        );
      }
    }

    final localUpdatedAt = _tryParseDateTime(
      localData['updated_at'] ?? localData['updatedAt'],
    );
    final remoteUpdatedAt = _tryParseDateTime(
      remoteData['updated_at'] ?? remoteData['updatedAt'],
    );

    if (localUpdatedAt != null && remoteUpdatedAt != null) {
      if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
        return ConflictResolutionResult(
          resolution: ConflictResolution.localWins,
          reason:
              'Last-write-wins: Local timestamp ($localUpdatedAt) is newer than remote ($remoteUpdatedAt).',
          winningData: localData,
        );
      } else if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
        return ConflictResolutionResult(
          resolution: ConflictResolution.remoteWins,
          reason:
              'Last-write-wins: Remote timestamp ($remoteUpdatedAt) is newer than local ($localUpdatedAt).',
          winningData: remoteData,
        );
      } else {
        return ConflictResolutionResult(
          resolution: ConflictResolution.remoteWins,
          reason:
              'Last-write-wins: Equal version and timestamp. Remote record chosen as tie-breaker.',
          winningData: remoteData,
        );
      }
    }

    if (localUpdatedAt != null && remoteUpdatedAt == null) {
      return ConflictResolutionResult(
        resolution: ConflictResolution.localWins,
        reason: 'Local timestamp available while remote timestamp missing.',
        winningData: localData,
      );
    }

    return ConflictResolutionResult(
      resolution: ConflictResolution.remoteWins,
      reason: 'Default fallback: remote record accepted.',
      winningData: remoteData,
    );
  }

  String _normalizeTableName(String name) {
    var normalized = name.trim().toLowerCase();
    if (normalized == 'notification_settings_table') {
      normalized = 'notification_settings';
    }
    return normalized;
  }

  bool _parseBool(dynamic val, [bool fallback = false]) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return fallback;
  }

  int? _tryParseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim());
    return null;
  }

  DateTime? _tryParseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is String && val.trim().isNotEmpty) {
      return DateTime.tryParse(val.trim());
    }
    return null;
  }
}
