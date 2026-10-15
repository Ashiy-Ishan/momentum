import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../adapters/desktop_adapter.dart';
import '../renderers/wallpaper_svg_renderer.dart';

class LinuxWallpaperService {
  static const String _prefEnabled = 'linux_wallpaper_enabled';
  static const String _prefAutoUpdate = 'linux_wallpaper_auto_update';
  static const String _prefOriginalWallpaper = 'linux_wallpaper_original_path';

  Timer? _debounceTimer;
  final DesktopEnvironment _env;

  LinuxWallpaperService() : _env = DesktopAdapter.detectEnvironment();

  DesktopEnvironment get environment => _env;
  bool get isSupported => Platform.isLinux && _env != DesktopEnvironment.unknown;

  Future<bool> isEnabled() async {
    if (!isSupported) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabled) ?? false;
  }

  Future<void> setEnabled(bool enabled, {WallpaperData? currentData}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, enabled);

    if (enabled) {
      // Record original wallpaper before first change
      final currentOriginal = prefs.getString(_prefOriginalWallpaper);
      if (currentOriginal == null || currentOriginal.isEmpty) {
        final existing = await DesktopAdapter.getCurrentWallpaper(_env);
        if (existing != null) {
          await prefs.setString(_prefOriginalWallpaper, existing);
        }
      }
      if (currentData != null) {
        await updateWallpaper(currentData);
      }
    }
  }

  Future<bool> isAutoUpdateEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefAutoUpdate) ?? true;
  }

  Future<void> setAutoUpdateEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoUpdate, enabled);
  }

  /// Debounced trigger for task/KPI changes
  void notifyDataChanged(WallpaperData data) {
    if (!isSupported) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 10), () async {
      final enabled = await isEnabled();
      final auto = await isAutoUpdateEnabled();
      if (enabled && auto) {
        await updateWallpaper(data);
      }
    });
  }

  /// Manually generate and apply wallpaper
  Future<bool> updateWallpaper(WallpaperData data) async {
    if (!isSupported) return false;

    try {
      final filePath = await WallpaperSvgRenderer.generateWallpaperImage(data);
      return await DesktopAdapter.applyWallpaper(filePath, _env);
    } catch (e) {
      debugPrint('Failed to update wallpaper: $e');
      return false;
    }
  }

  /// Restore user's previous original wallpaper
  Future<bool> restoreOriginalWallpaper() async {
    if (!isSupported) return false;
    final prefs = await SharedPreferences.getInstance();
    final original = prefs.getString(_prefOriginalWallpaper);
    if (original != null && original.isNotEmpty) {
      final success = await DesktopAdapter.restoreWallpaper(original, _env);
      if (success) {
        await prefs.remove(_prefOriginalWallpaper);
        await prefs.setBool(_prefEnabled, false);
      }
      return success;
    }
    return false;
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
