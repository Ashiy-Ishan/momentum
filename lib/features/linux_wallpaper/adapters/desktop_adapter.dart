import 'dart:io';
import 'package:flutter/foundation.dart';

enum DesktopEnvironment {
  gnome,
  kde,
  xfce,
  unknown,
}

abstract class DesktopAdapter {
  static DesktopEnvironment detectEnvironment() {
    if (!Platform.isLinux) return DesktopEnvironment.unknown;

    final desktop = (Platform.environment['XDG_CURRENT_DESKTOP'] ??
            Platform.environment['DESKTOP_SESSION'] ??
            '')
        .toLowerCase();

    if (desktop.contains('gnome') || desktop.contains('unity')) {
      return DesktopEnvironment.gnome;
    } else if (desktop.contains('kde') || desktop.contains('plasma')) {
      return DesktopEnvironment.kde;
    } else if (desktop.contains('xfce')) {
      return DesktopEnvironment.xfce;
    }

    return DesktopEnvironment.unknown;
  }

  static Future<String?> getCurrentWallpaper(DesktopEnvironment env) async {
    if (!Platform.isLinux) return null;

    try {
      switch (env) {
        case DesktopEnvironment.gnome:
          final result = await Process.run('gsettings', [
            'get',
            'org.gnome.desktop.background',
            'picture-uri',
          ]);
          if (result.exitCode == 0) {
            return result.stdout.toString().trim().replaceAll("'", '');
          }
          break;
        case DesktopEnvironment.kde:
          final home = Platform.environment['HOME'] ?? '';
          final configFile = File('$home/.config/plasma-org.kde.plasma.desktop-appletsrc');
          if (await configFile.exists()) {
            final content = await configFile.readAsString();
            final match = RegExp(r'Image=(.*)').firstMatch(content);
            if (match != null) return match.group(1)?.trim();
          }
          break;
        case DesktopEnvironment.xfce:
          final result = await Process.run('xfconf-query', [
            '-c',
            'xfce4-desktop',
            '-p',
            '/backdrop/screen0/monitor0/workspace0/last-image',
          ]);
          if (result.exitCode == 0) {
            return result.stdout.toString().trim();
          }
          break;
        case DesktopEnvironment.unknown:
          break;
      }
    } catch (e) {
      debugPrint('Error getting current wallpaper: $e');
    }
    return null;
  }

  static Future<bool> applyWallpaper(String imagePath, DesktopEnvironment env) async {
    if (!Platform.isLinux) return false;

    final file = File(imagePath);
    if (!await file.exists()) {
      debugPrint('Wallpaper file does not exist: $imagePath');
      return false;
    }

    try {
      final fileUri = file.uri.toString();

      switch (env) {
        case DesktopEnvironment.gnome:
          final lightRes = await Process.run('gsettings', [
            'set',
            'org.gnome.desktop.background',
            'picture-uri',
            fileUri,
          ]);
          final darkRes = await Process.run('gsettings', [
            'set',
            'org.gnome.desktop.background',
            'picture-uri-dark',
            fileUri,
          ]);
          return lightRes.exitCode == 0 || darkRes.exitCode == 0;

        case DesktopEnvironment.kde:
          final res = await Process.run('plasma-apply-wallpaperimage', [imagePath]);
          return res.exitCode == 0;

        case DesktopEnvironment.xfce:
          final res = await Process.run('xfconf-query', [
            '-c',
            'xfce4-desktop',
            '-p',
            '/backdrop/screen0/monitor0/workspace0/last-image',
            '-s',
            imagePath,
          ]);
          return res.exitCode == 0;

        case DesktopEnvironment.unknown:
          try {
            final feh = await Process.run('feh', ['--bg-fill', imagePath]);
            if (feh.exitCode == 0) return true;
          } catch (_) {}
          return false;
      }
    } catch (e) {
      debugPrint('Error applying wallpaper: $e');
      return false;
    }
  }

  static Future<bool> restoreWallpaper(String originalValue, DesktopEnvironment env) async {
    if (!Platform.isLinux) return false;

    try {
      switch (env) {
        case DesktopEnvironment.gnome:
          await Process.run('gsettings', [
            'set',
            'org.gnome.desktop.background',
            'picture-uri',
            originalValue.startsWith('file://') ? originalValue : "'$originalValue'",
          ]);
          await Process.run('gsettings', [
            'set',
            'org.gnome.desktop.background',
            'picture-uri-dark',
            originalValue.startsWith('file://') ? originalValue : "'$originalValue'",
          ]);
          return true;

        case DesktopEnvironment.kde:
          final res = await Process.run('plasma-apply-wallpaperimage', [originalValue]);
          return res.exitCode == 0;

        case DesktopEnvironment.xfce:
          final res = await Process.run('xfconf-query', [
            '-c',
            'xfce4-desktop',
            '-p',
            '/backdrop/screen0/monitor0/workspace0/last-image',
            '-s',
            originalValue,
          ]);
          return res.exitCode == 0;

        case DesktopEnvironment.unknown:
          return false;
      }
    } catch (e) {
      debugPrint('Error restoring wallpaper: $e');
      return false;
    }
  }
}
