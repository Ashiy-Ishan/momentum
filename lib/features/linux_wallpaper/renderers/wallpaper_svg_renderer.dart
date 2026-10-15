import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class WallpaperData {
  final DateTime date;
  final int completedTasks;
  final int totalTasks;
  final int currentStreak;
  final String motivationalQuote;
  final String quoteAuthor;
  final Map<String, ({int completed, int total})> parentLabelProgress;
  final bool isDark;

  const WallpaperData({
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.currentStreak,
    required this.motivationalQuote,
    this.quoteAuthor = '',
    required this.parentLabelProgress,
    this.isDark = true,
  });

  int get completionPercentage =>
      totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;
}

class WallpaperSvgRenderer {
  /// Renders dashboard statistics into a high-resolution 1920x1080 SVG document.
  static String renderSvg(WallpaperData data) {
    final bgStart = data.isDark ? '#0B0F19' : '#F8FAFC';
    final bgEnd = data.isDark ? '#151C2C' : '#EEF2F6';
    final cardBg = data.isDark ? 'rgba(30, 41, 59, 0.7)' : 'rgba(255, 255, 255, 0.85)';
    final cardBorder = data.isDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.08)';
    final textPrimary = data.isDark ? '#FFFFFF' : '#0F172A';
    final textSecondary = data.isDark ? '#94A3B8' : '#64748B';
    const accentIndigo = '#6366F1';
    const accentTeal = '#10B981';

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(data.date);
    final pct = data.completionPercentage;

    // Build parent label cards
    final labelEntries = data.parentLabelProgress.entries.take(5).toList();
    final buffer = StringBuffer();

    for (var i = 0; i < labelEntries.length; i++) {
      final entry = labelEntries[i];
      final yOffset = 520 + (i * 65);
      final labelPct = entry.value.total > 0
          ? ((entry.value.completed / entry.value.total) * 100).round()
          : 0;

      buffer.write('''
      <g transform="translate(180, $yOffset)">
        <rect width="460" height="52" rx="10" fill="$cardBg" stroke="$cardBorder" stroke-width="1"/>
        <text x="20" y="32" font-family="sans-serif" font-size="16" font-weight="600" fill="$textPrimary">${_escapeXml(entry.key)}</text>
        <text x="260" y="32" font-family="sans-serif" font-size="14" fill="$textSecondary">${entry.value.completed}/${entry.value.total} ($labelPct%)</text>
        <rect x="360" y="24" width="80" height="8" rx="4" fill="${data.isDark ? '#334155' : '#E2E8F0'}"/>
        <rect x="360" y="24" width="${80 * (labelPct / 100)}" height="8" rx="4" fill="$accentIndigo"/>
      </g>
      ''');
    }

    return '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1920" height="1080" viewBox="0 0 1920 1080" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGrad" x1="0" y1="0" x2="1920" y2="1080" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="$bgStart"/>
      <stop offset="100%" stop-color="$bgEnd"/>
    </linearGradient>
    <linearGradient id="progGrad" x1="0" y1="0" x2="400" y2="0" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="$accentIndigo"/>
      <stop offset="100%" stop-color="$accentTeal"/>
    </linearGradient>
    <filter id="shadow" x="-10" y="-10" width="1940" height="1100" filterUnits="userSpaceOnUse">
      <feDropShadow dx="0" dy="8" stdDeviation="16" flood-color="#000" flood-opacity="0.3"/>
    </filter>
  </defs>

  <!-- Background -->
  <rect width="1920" height="1080" fill="url(#bgGrad)"/>

  <!-- Subtle grid lines or pattern -->
  <circle cx="1500" cy="300" r="400" fill="$accentIndigo" opacity="0.04"/>
  <circle cx="400" cy="800" r="300" fill="$accentTeal" opacity="0.04"/>

  <!-- Left Main Card: Momentum Overview -->
  <g transform="translate(140, 120)">
    <!-- Header -->
    <text x="0" y="40" font-family="sans-serif" font-size="20" font-weight="700" letter-spacing="4" fill="$accentIndigo">MOMENTUM PRODUCTIVITY</text>
    <text x="0" y="90" font-family="sans-serif" font-size="44" font-weight="800" fill="$textPrimary">$dateStr</text>
    
    <!-- Today's Progress Card -->
    <rect x="0" y="130" width="540" height="210" rx="20" fill="$cardBg" stroke="$cardBorder" stroke-width="1" filter="url(#shadow)"/>
    <text x="36" y="180" font-family="sans-serif" font-size="16" font-weight="600" fill="$textSecondary">TODAY'S COMPLETION</text>
    <text x="36" y="240" font-family="sans-serif" font-size="52" font-weight="800" fill="$textPrimary">${data.completedTasks}<tspan font-size="28" font-weight="500" fill="$textSecondary"> / ${data.totalTasks} tasks</tspan></text>
    <text x="440" y="240" font-family="sans-serif" font-size="42" font-weight="800" fill="$accentTeal">$pct%</text>

    <!-- Progress Bar -->
    <rect x="36" y="275" width="468" height="14" rx="7" fill="${data.isDark ? '#334155' : '#E2E8F0'}"/>
    <rect x="36" y="275" width="${468 * (pct / 100)}" height="14" rx="7" fill="url(#progGrad)"/>
  </g>

  <!-- Middle Stats / Streak Card -->
  <g transform="translate(740, 250)">
    <rect width="360" height="210" rx="20" fill="$cardBg" stroke="$cardBorder" stroke-width="1" filter="url(#shadow)"/>
    <text x="36" y="50" font-family="sans-serif" font-size="16" font-weight="600" fill="$textSecondary">CONSISTENCY STREAK</text>
    <text x="36" y="125" font-family="sans-serif" font-size="56" font-weight="800" fill="#F59E0B">🔥 ${data.currentStreak} <tspan font-size="24" font-weight="600" fill="$textSecondary">days</tspan></text>
    <text x="36" y="165" font-family="sans-serif" font-size="14" fill="$textSecondary">Stay consistent. Every day counts.</text>
  </g>

  <!-- Parent Labels Section -->
  <g transform="translate(140, 480)">
    <text x="0" y="15" font-family="sans-serif" font-size="18" font-weight="700" letter-spacing="1" fill="$textSecondary">KEY FOCUS AREAS</text>
  </g>
  ${buffer.toString()}

  <!-- Motivational Quote Footer Card -->
  <g transform="translate(140, 920)">
    <rect width="960" height="80" rx="16" fill="$cardBg" stroke="$cardBorder" stroke-width="1"/>
    <text x="36" y="46" font-family="sans-serif" font-size="18" font-style="italic" fill="$textPrimary">"${_escapeXml(data.motivationalQuote)}"</text>
    ${data.quoteAuthor.isNotEmpty ? '<text x="860" y="46" font-family="sans-serif" font-size="14" fill="$textSecondary">— ${_escapeXml(data.quoteAuthor)}</text>' : ''}
  </g>
</svg>''';
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Saves SVG to application documents/wallpaper directory and converts to PNG if possible.
  static Future<String> generateWallpaperImage(WallpaperData data) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final wallpaperDir = Directory(p.join(docsDir.path, 'wallpapers'));
    if (!await wallpaperDir.exists()) {
      await wallpaperDir.create(recursive: true);
    }

    final svgContent = renderSvg(data);
    final svgFile = File(p.join(wallpaperDir.path, 'momentum_wallpaper.svg'));
    await svgFile.writeAsString(svgContent);

    // Convert SVG to PNG using imagemagick convert if available
    final pngPath = p.join(wallpaperDir.path, 'momentum_wallpaper.png');
    try {
      final res = await Process.run('convert', [
        '-background',
        'none',
        svgFile.path,
        pngPath,
      ]);
      if (res.exitCode == 0 && await File(pngPath).exists()) {
        return pngPath;
      }
    } catch (_) {}

    // If convert is not available, return svg directly (modern GNOME/KDE support SVG wallpapers)
    return svgFile.path;
  }
}
