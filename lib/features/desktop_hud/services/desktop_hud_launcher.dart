import 'dart:io';

import 'package:flutter/foundation.dart';

/// Manages launching and tracking the standalone independent Desktop HUD process.
///
/// Spawns `momentum --hud` in a detached process with independent GTK window hints
/// (undecorated, sticky, skip-taskbar, desktop layer) so the HUD remains visible and
/// interactive on the desktop even when the main Momentum window is minimized or closed.
class DesktopHudLauncher {
  static Process? _runningProcess;

  static bool get isRunning => _runningProcess != null;

  /// Launches the standalone Desktop HUD window as a detached process
  static Future<bool> launchStandaloneHud() async {
    try {
      final exe = Platform.resolvedExecutable;
      debugPrint('Launching standalone Desktop HUD: $exe --hud');
      final process = await Process.start(
        exe,
        ['--hud'],
        mode: ProcessStartMode.detached,
      );
      _runningProcess = process;
      return true;
    } catch (e) {
      debugPrint('Failed to launch standalone Desktop HUD: $e');
      return false;
    }
  }

  /// Closes the tracked standalone HUD process if active
  static void closeStandaloneHud() {
    try {
      _runningProcess?.kill();
      _runningProcess = null;
    } catch (e) {
      debugPrint('Error closing standalone HUD: $e');
    }
  }
}
