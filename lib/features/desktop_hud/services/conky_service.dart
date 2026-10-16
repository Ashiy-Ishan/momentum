import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../domain/models/models.dart';

/// Service managing native Linux Conky system monitor integration.
///
/// Generates and maintains ~/.config/conky/momentum_conky.conf and dynamic
/// live telemetry at ~/.config/conky/momentum_data.txt. Launches, monitors,
/// and stops the native /usr/bin/conky daemon so Momentum tasks, streaks,
/// and KPIs remain visible directly on the desktop wallpaper even when the
/// main application is minimized or closed.
class ConkyService {
  static const String configDirName = '.config/conky';
  static const String configFileName = 'momentum_conky.conf';
  static const String dataFileName = 'momentum_data.txt';

  static Directory _getConkyDir() {
    final home = Platform.environment['HOME'] ?? '/home/${Platform.environment['USER'] ?? 'user'}';
    final dir = Directory('$home/$configDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static File getConfigFile() {
    final dir = _getConkyDir();
    return File('${dir.path}/$configFileName');
  }

  static File getDataFile() {
    final dir = _getConkyDir();
    return File('${dir.path}/$dataFileName');
  }

  /// Check if /usr/bin/conky or conky binary is installed on the system
  static Future<bool> isConkyInstalled() async {
    if (!Platform.isLinux) return false;
    try {
      if (File('/usr/bin/conky').existsSync()) return true;
      final res = await Process.run('which', ['conky']);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Check if Momentum's Conky daemon is currently running in background
  static Future<bool> isConkyRunning() async {
    if (!Platform.isLinux) return false;
    try {
      final res = await Process.run('pgrep', ['-f', configFileName]);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Generates the modern Lua Conky configuration file
  static Future<File> ensureConfigFileExists({bool overwrite = false}) async {
    final file = getConfigFile();
    if (file.existsSync() && !overwrite) return file;

    final dataFilePath = getDataFile().path;

    final configContent = '''-- Momentum Desktop Conky Configuration
-- Auroral Jade Theme for Linux Desktop
conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = '#E2E8F0',
    default_outline_color = '#000000',
    default_shade_color = '#000000',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = false,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans:size=10',
    gap_x = 32,
    gap_y = 54,
    minimum_height = 200,
    minimum_width = 340,
    maximum_width = 380,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'normal',
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_transparent = false,
    own_window_argb_visual = true,
    own_window_argb_value = 210,
    own_window_colour = '#090D16',
    update_interval = 2.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
}

conky.text = [[
\${color #14B8A6}\${font DejaVu Sans:bold:size=12}MOMENTUM DESKTOP HUD\${font}
\${color #334155}\${hr 1}
\${color #94A3B8}TIME: \${color #F8FAFC}\${font DejaVu Sans:bold:size=11}\${time %H:%M:%S}\${font}   \${color #94A3B8}DATE: \${color #F8FAFC}\${time %a, %d %b}
\${color #334155}\${hr 1}
\${execpi 2 cat $dataFilePath}
]]
''';

    await file.writeAsString(configContent);
    return file;
  }

  /// Updates ~/.config/conky/momentum_data.txt with the latest tasks, streak & KPIs
  static Future<void> updateConkyData({
    required int streakDays,
    required double completionRate,
    required List<Task> tasks,
    required List<KpiDefinition> kpis,
  }) async {
    if (!Platform.isLinux) return;
    try {
      final dataFile = getDataFile();

      final buffer = StringBuffer();

      // Daily streak & completion bar
      final pct = (completionRate * 100).toInt().clamp(0, 100);
      buffer.writeln(r'${color #14B8A6}${font DejaVu Sans:bold:size=10}DAILY PROGRESS & STREAK${font}');
      buffer.writeln('\${color #94A3B8}Streak: \${color #F59E0B}🔥 $streakDays Days\${color #94A3B8}   Completion: \${color #10B981}$pct%');
      buffer.writeln('\${color #10B981}\${execbar echo $pct}');
      buffer.writeln();

      // Active Platform KPIs (up to 3)
      if (kpis.isNotEmpty) {
        buffer.writeln(r'${color #14B8A6}${font DejaVu Sans:bold:size=10}CREATOR & DEV KPIS${font}');
        for (final kpi in kpis.take(3)) {
          final current = kpi.currentValue.toStringAsFixed(kpi.currentValue % 1 == 0 ? 0 : 1);
          final target = kpi.targetValue.toStringAsFixed(kpi.targetValue % 1 == 0 ? 0 : 1);
          buffer.writeln('\${color #E2E8F0}${kpi.name}: \${color #38BDF8}$current / $target ${kpi.unit}');
        }
        buffer.writeln();
      }

      // Today's Tasks (up to 5)
      buffer.writeln(r"${color #14B8A6}${font DejaVu Sans:bold:size=10}TODAY'S TASKS${font}");
      if (tasks.isEmpty) {
        buffer.writeln(r'${color #64748B}No tasks scheduled for today.');
      } else {
        for (final task in tasks.take(5)) {
          final isDone = task.status.name == 'done';
          final checkIcon = isDone ? '[✓]' : '[ ]';
          final textColor = isDone ? '#10B981' : '#E2E8F0';
          buffer.writeln('\${color $textColor}$checkIcon ${task.title}');
        }
        if (tasks.length > 5) {
          buffer.writeln('\${color #64748B}... and ${tasks.length - 5} more tasks in app');
        }
      }

      await dataFile.writeAsString(buffer.toString());
    } catch (e) {
      debugPrint('Failed to write Conky telemetry: $e');
    }
  }

  /// Launch the background native Conky daemon
  static Future<bool> startConky() async {
    if (!Platform.isLinux) return false;
    try {
      final installed = await isConkyInstalled();
      if (!installed) {
        debugPrint('Conky binary not installed on Linux system.');
        return false;
      }

      final configFile = await ensureConfigFileExists();

      // Ensure data file exists with initial content
      final dataFile = getDataFile();
      if (!dataFile.existsSync()) {
        await dataFile.writeAsString(r'${color #14B8A6}Momentum Conky Initialized.${font}');
      }

      // Stop previous instance if running
      await stopConky();

      // Launch conky in daemon mode (-d) with our config (-c)
      final res = await Process.run('conky', ['-c', configFile.path, '-d']);
      return res.exitCode == 0;
    } catch (e) {
      debugPrint('Failed to start Conky daemon: $e');
      return false;
    }
  }

  /// Gracefully stops the native conky daemon
  static Future<bool> stopConky() async {
    if (!Platform.isLinux) return false;
    try {
      final res = await Process.run('pkill', ['-f', configFileName]);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
