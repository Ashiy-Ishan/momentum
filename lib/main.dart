import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/theme.dart';
import 'data/remote/supabase_client.dart';
import 'data/sync/sync_engine.dart';
import 'features/desktop_hud/screens/desktop_hud_screen.dart';
import 'features/notifications/services/notification_service.dart';
import 'shared/providers/database_provider.dart';

void main([List<String> args = const []]) async {
  WidgetsFlutterBinding.ensureInitialized();

  final isHudMode = args.contains('--hud') || args.contains('--desktop-hud');

  // 1. Initialize SharedPreferences for persistent settings
  await SharedPreferences.getInstance();

  // 2. Initialize Local Notifications safely (graceful fallback on desktop)
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService init notice: $e');
  }

  // 3. Initialize Supabase client if configured
  try {
    await MomentumSupabaseClient.instance.initialize();
  } catch (e) {
    debugPrint('SupabaseClient init notice: $e');
  }

  // 4. Run application with configured Riverpod ProviderScope
  final container = ProviderContainer();

  // 5. Sync currentUserIdProvider with Supabase auth status on boot
  final currentUser = MomentumSupabaseClient.instance.currentUser;
  if (currentUser != null) {
    container.read(currentUserIdProvider.notifier).state = currentUser.id;
  }

  // 6. Eagerly boot SyncEngine to establish network listeners, auth stream, and sync
  try {
    container.read(syncEngineProvider);
  } catch (e) {
    debugPrint('SyncEngine boot init notice: $e');
  }


  runApp(
    UncontrolledProviderScope(
      container: container,
      child: isHudMode ? const DesktopHudStandaloneApp() : const MomentumApp(),
    ),
  );
}

/// Standalone desktop overlay application for HUD (Conky mode)
class DesktopHudStandaloneApp extends StatelessWidget {
  const DesktopHudStandaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum Desktop HUD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const Scaffold(
        backgroundColor: Colors.transparent,
        body: DesktopHudScreen(isStandalone: true),
      ),
    );
  }
}
