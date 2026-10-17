import 'dart:io';

import 'package:flutter/foundation.dart';

class DesktopHudLauncher {
  static Process? _runningProcess;

  static bool get isRunning => _runningProcess != null;

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

  static void closeStandaloneHud() {
    try {
      _runningProcess?.kill();
      _runningProcess = null;
    } catch (e) {
      debugPrint('Error closing standalone HUD: $e');
    }
  }
}
