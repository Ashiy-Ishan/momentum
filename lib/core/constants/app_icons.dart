import 'package:flutter/material.dart';

class IconCategory {
  final String name;
  final List<IconItem> icons;

  const IconCategory({required this.name, required this.icons});
}

class IconItem {
  final String name;
  final IconData iconData;
  final String category;

  const IconItem({
    required this.name,
    required this.iconData,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IconItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          iconData == other.iconData &&
          category == other.category;

  @override
  int get hashCode => Object.hash(name, iconData, category);
}

abstract class AppIcons {
  static final List<IconCategory> _categories = [
    const IconCategory(
      name: 'Productivity',
      icons: [
        IconItem(
          name: 'task_alt',
          iconData: Icons.task_alt,
          category: 'Productivity',
        ),
        IconItem(
          name: 'check_circle',
          iconData: Icons.check_circle_outline,
          category: 'Productivity',
        ),
        IconItem(
          name: 'timer',
          iconData: Icons.timer_outlined,
          category: 'Productivity',
        ),
        IconItem(
          name: 'flag',
          iconData: Icons.flag_outlined,
          category: 'Productivity',
        ),
        IconItem(
          name: 'schedule',
          iconData: Icons.schedule,
          category: 'Productivity',
        ),
        IconItem(
          name: 'trending_up',
          iconData: Icons.trending_up,
          category: 'Productivity',
        ),
        IconItem(
          name: 'assignment',
          iconData: Icons.assignment_outlined,
          category: 'Productivity',
        ),
        IconItem(
          name: 'alarm',
          iconData: Icons.alarm,
          category: 'Productivity',
        ),
        IconItem(
          name: 'checklist',
          iconData: Icons.checklist,
          category: 'Productivity',
        ),
        IconItem(name: 'bolt', iconData: Icons.bolt, category: 'Productivity'),
        IconItem(
          name: 'calendar',
          iconData: Icons.calendar_today_outlined,
          category: 'Productivity',
        ),
        IconItem(
          name: 'hourglass',
          iconData: Icons.hourglass_empty,
          category: 'Productivity',
        ),
        IconItem(
          name: 'track_changes',
          iconData: Icons.track_changes,
          category: 'Productivity',
        ),
      ],
    ),

    const IconCategory(
      name: 'Learning',
      icons: [
        IconItem(
          name: 'school',
          iconData: Icons.school_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'book',
          iconData: Icons.menu_book_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'auto_stories',
          iconData: Icons.auto_stories_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'library',
          iconData: Icons.local_library_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'translate',
          iconData: Icons.translate,
          category: 'Learning',
        ),
        IconItem(
          name: 'calculate',
          iconData: Icons.calculate_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'science',
          iconData: Icons.science_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'psychology',
          iconData: Icons.psychology_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'history_edu',
          iconData: Icons.history_edu_outlined,
          category: 'Learning',
        ),
        IconItem(
          name: 'quiz',
          iconData: Icons.quiz_outlined,
          category: 'Learning',
        ),
      ],
    ),

    const IconCategory(
      name: 'Content Creation',
      icons: [
        IconItem(
          name: 'edit',
          iconData: Icons.edit_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'brush',
          iconData: Icons.brush_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'videocam',
          iconData: Icons.videocam_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'movie',
          iconData: Icons.movie_creation_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'mic',
          iconData: Icons.mic_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'camera',
          iconData: Icons.photo_camera_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'palette',
          iconData: Icons.palette_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'design',
          iconData: Icons.design_services_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'draw',
          iconData: Icons.draw_outlined,
          category: 'Content Creation',
        ),
        IconItem(
          name: 'music',
          iconData: Icons.music_note_outlined,
          category: 'Content Creation',
        ),
      ],
    ),

    const IconCategory(
      name: 'Social Media',
      icons: [
        IconItem(
          name: 'share',
          iconData: Icons.share_outlined,
          category: 'Social Media',
        ),
        IconItem(
          name: 'public',
          iconData: Icons.public,
          category: 'Social Media',
        ),
        IconItem(
          name: 'forum',
          iconData: Icons.forum_outlined,
          category: 'Social Media',
        ),
        IconItem(
          name: 'chat',
          iconData: Icons.chat_bubble_outline,
          category: 'Social Media',
        ),
        IconItem(
          name: 'thumb_up',
          iconData: Icons.thumb_up_outlined,
          category: 'Social Media',
        ),
        IconItem(name: 'tag', iconData: Icons.tag, category: 'Social Media'),
        IconItem(
          name: 'campaign',
          iconData: Icons.campaign_outlined,
          category: 'Social Media',
        ),
        IconItem(
          name: 'send',
          iconData: Icons.send_outlined,
          category: 'Social Media',
        ),
        IconItem(
          name: 'bookmark',
          iconData: Icons.bookmark_outline,
          category: 'Social Media',
        ),
        IconItem(
          name: 'favorite',
          iconData: Icons.favorite_outline,
          category: 'Social Media',
        ),
      ],
    ),

    const IconCategory(
      name: 'Personal',
      icons: [
        IconItem(
          name: 'person',
          iconData: Icons.person_outline,
          category: 'Personal',
        ),
        IconItem(
          name: 'fitness',
          iconData: Icons.fitness_center,
          category: 'Personal',
        ),
        IconItem(
          name: 'meditation',
          iconData: Icons.self_improvement,
          category: 'Personal',
        ),
        IconItem(
          name: 'bed',
          iconData: Icons.bed_outlined,
          category: 'Personal',
        ),
        IconItem(
          name: 'restaurant',
          iconData: Icons.restaurant_outlined,
          category: 'Personal',
        ),
        IconItem(
          name: 'run',
          iconData: Icons.directions_run,
          category: 'Personal',
        ),
        IconItem(
          name: 'walk',
          iconData: Icons.directions_walk,
          category: 'Personal',
        ),
        IconItem(
          name: 'cleaning',
          iconData: Icons.cleaning_services_outlined,
          category: 'Personal',
        ),
        IconItem(
          name: 'spa',
          iconData: Icons.spa_outlined,
          category: 'Personal',
        ),
        IconItem(
          name: 'home',
          iconData: Icons.home_outlined,
          category: 'Personal',
        ),
      ],
    ),

    const IconCategory(
      name: 'Technical',
      icons: [
        IconItem(name: 'code', iconData: Icons.code, category: 'Technical'),
        IconItem(
          name: 'terminal',
          iconData: Icons.terminal,
          category: 'Technical',
        ),
        IconItem(
          name: 'computer',
          iconData: Icons.computer,
          category: 'Technical',
        ),
        IconItem(
          name: 'bug',
          iconData: Icons.bug_report_outlined,
          category: 'Technical',
        ),
        IconItem(name: 'memory', iconData: Icons.memory, category: 'Technical'),
        IconItem(
          name: 'storage',
          iconData: Icons.storage,
          category: 'Technical',
        ),
        IconItem(
          name: 'developer',
          iconData: Icons.developer_mode,
          category: 'Technical',
        ),
        IconItem(
          name: 'lan',
          iconData: Icons.lan_outlined,
          category: 'Technical',
        ),
        IconItem(
          name: 'integration',
          iconData: Icons.integration_instructions_outlined,
          category: 'Technical',
        ),
        IconItem(name: 'api', iconData: Icons.api, category: 'Technical'),
      ],
    ),
  ];

  static List<IconCategory> get categories => _categories;

  static final List<IconItem> allIcons = [
    for (final cat in _categories) ...cat.icons,
  ];

  static final Map<String, IconData> _nameToIcon = {
    for (final item in allIcons) item.name.toLowerCase(): item.iconData,
  };

  static final Map<IconData, String> _iconToName = {
    for (final item in allIcons) item.iconData: item.name,
  };

  static IconData fromName(
    String name, {
    IconData fallback = Icons.circle_outlined,
  }) {
    final key = name.toLowerCase().trim();
    return _nameToIcon[key] ?? fallback;
  }

  static String nameOf(IconData icon, {String fallback = 'circle_outlined'}) {
    return _iconToName[icon] ?? fallback;
  }

  static List<IconItem> search(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      return List<IconItem>.unmodifiable(allIcons);
    }
    return allIcons.where((item) {
      return item.name.toLowerCase().contains(cleanQuery) ||
          item.category.toLowerCase().contains(cleanQuery);
    }).toList();
  }
}
