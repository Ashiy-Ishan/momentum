import 'package:flutter/material.dart';

import '../../domain/models/label.dart';
import '../theme/app_colors.dart';
import 'app_icons.dart';

export '../../domain/models/label.dart';

/// Extension providing theme and visual convenience methods on the domain [Label].
extension LabelVisualsExtension on Label {
  /// Converts the hex color string (e.g. #EF4444) to a Flutter [Color].
  Color get colorAsColor {
    final cleanHex = color.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      final value = int.tryParse('0xFF$cleanHex');
      if (value != null) return Color(value);
    } else if (cleanHex.length == 8) {
      final value = int.tryParse('0x$cleanHex');
      if (value != null) return Color(value);
    }
    return AppColors.primary;
  }

  /// Resolves the corresponding Material [IconData] via [AppIcons].
  IconData get iconData => AppIcons.fromName(iconName);

  /// Whether this label is a sub-label under a parent category.
  bool get isSubLabel => parentId != null && parentId!.isNotEmpty;
}

/// Pre-seeded default labels and hierarchical sub-labels for Momentum users.
abstract class DefaultLabels {
  /// Generate the complete initial set of default labels for a given user.
  static List<Label> getDefaults(String userId) {
    final now = DateTime.now();

    // Deterministic parent IDs
    final youtubeId = 'label_${userId}_youtube';
    final socialId = 'label_${userId}_social_media';
    final learningId = 'label_${userId}_learning';
    final careerId = 'label_${userId}_career';
    final personalId = 'label_${userId}_personal';

    return [
      // -----------------------------------------------------------------------
      // 1. YouTube (with Channel 1, 2, 3 sub-labels)
      // -----------------------------------------------------------------------
      Label(
        id: youtubeId,
        userId: userId,
        parentId: null,
        name: 'YouTube',
        iconName: 'videocam',
        color: '#EF4444',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${youtubeId}_channel_1',
        userId: userId,
        parentId: youtubeId,
        name: 'Channel 1',
        iconName: 'videocam',
        color: '#EF4444',
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${youtubeId}_channel_2',
        userId: userId,
        parentId: youtubeId,
        name: 'Channel 2',
        iconName: 'videocam',
        color: '#F43F5E',
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${youtubeId}_channel_3',
        userId: userId,
        parentId: youtubeId,
        name: 'Channel 3',
        iconName: 'videocam',
        color: '#DC2626',
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 2. Social Media (Instagram, X, Facebook, TikTok, Other)
      // -----------------------------------------------------------------------
      Label(
        id: socialId,
        userId: userId,
        parentId: null,
        name: 'Social Media',
        iconName: 'share',
        color: '#3B82F6',
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${socialId}_instagram',
        userId: userId,
        parentId: socialId,
        name: 'Instagram',
        iconName: 'camera',
        color: '#EC4899',
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${socialId}_x',
        userId: userId,
        parentId: socialId,
        name: 'X',
        iconName: 'tag',
        color: '#475569',
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${socialId}_facebook',
        userId: userId,
        parentId: socialId,
        name: 'Facebook',
        iconName: 'public',
        color: '#1877F2',
        sortOrder: 7,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${socialId}_tiktok',
        userId: userId,
        parentId: socialId,
        name: 'TikTok',
        iconName: 'music',
        color: '#06B6D4',
        sortOrder: 8,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${socialId}_other',
        userId: userId,
        parentId: socialId,
        name: 'Other',
        iconName: 'forum',
        color: '#8B5CF6',
        sortOrder: 9,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 3. Learning (Programming, Linux, University, German, English)
      // -----------------------------------------------------------------------
      Label(
        id: learningId,
        userId: userId,
        parentId: null,
        name: 'Learning',
        iconName: 'school',
        color: '#10B981',
        sortOrder: 10,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${learningId}_programming',
        userId: userId,
        parentId: learningId,
        name: 'Programming',
        iconName: 'code',
        color: '#6366F1',
        sortOrder: 11,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${learningId}_linux',
        userId: userId,
        parentId: learningId,
        name: 'Linux',
        iconName: 'terminal',
        color: '#F59E0B',
        sortOrder: 12,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${learningId}_university',
        userId: userId,
        parentId: learningId,
        name: 'University',
        iconName: 'school',
        color: '#10B981',
        sortOrder: 13,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${learningId}_german',
        userId: userId,
        parentId: learningId,
        name: 'German',
        iconName: 'translate',
        color: '#F97316',
        sortOrder: 14,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${learningId}_english',
        userId: userId,
        parentId: learningId,
        name: 'English',
        iconName: 'translate',
        color: '#06B6D4',
        sortOrder: 15,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 4. Career (Internship, CV, Interview, Portfolio)
      // -----------------------------------------------------------------------
      Label(
        id: careerId,
        userId: userId,
        parentId: null,
        name: 'Career',
        iconName: 'assignment',
        color: '#6366F1',
        sortOrder: 16,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${careerId}_internship',
        userId: userId,
        parentId: careerId,
        name: 'Internship',
        iconName: 'flag',
        color: '#3B82F6',
        sortOrder: 17,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${careerId}_cv',
        userId: userId,
        parentId: careerId,
        name: 'CV',
        iconName: 'edit',
        color: '#8B5CF6',
        sortOrder: 18,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${careerId}_interview',
        userId: userId,
        parentId: careerId,
        name: 'Interview',
        iconName: 'chat',
        color: '#14B8A6',
        sortOrder: 19,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${careerId}_portfolio',
        userId: userId,
        parentId: careerId,
        name: 'Portfolio',
        iconName: 'design',
        color: '#EC4899',
        sortOrder: 20,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 5. Personal (Daily Routine, Reading, Room Cleaning, Projects)
      // -----------------------------------------------------------------------
      Label(
        id: personalId,
        userId: userId,
        parentId: null,
        name: 'Personal',
        iconName: 'person',
        color: '#F59E0B',
        sortOrder: 21,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${personalId}_routine',
        userId: userId,
        parentId: personalId,
        name: 'Daily Routine',
        iconName: 'schedule',
        color: '#0284C7',
        sortOrder: 22,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${personalId}_reading',
        userId: userId,
        parentId: personalId,
        name: 'Reading',
        iconName: 'book',
        color: '#8B5CF6',
        sortOrder: 23,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${personalId}_cleaning',
        userId: userId,
        parentId: personalId,
        name: 'Room Cleaning',
        iconName: 'cleaning',
        color: '#10B981',
        sortOrder: 24,
        createdAt: now,
        updatedAt: now,
      ),
      Label(
        id: '${personalId}_projects',
        userId: userId,
        parentId: personalId,
        name: 'Projects',
        iconName: 'bolt',
        color: '#F97316',
        sortOrder: 25,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Returns only root parent labels.
  static List<Label> getParentDefaults(String userId) {
    return getDefaults(userId).where((l) => l.parentId == null).toList();
  }

  /// Returns sub-labels for a specific parent label.
  static List<Label> getSubLabelsFor(String userId, String parentId) {
    return getDefaults(userId).where((l) => l.parentId == parentId).toList();
  }
}
