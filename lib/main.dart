import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/remote/supabase_client.dart';
import 'features/notifications/services/notification_service.dart';
import 'shared/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // 5. Seed default labels if user has no labels yet
  try {
    final userId = container.read(currentUserIdProvider);
    final labelRepo = container.read(labelRepositoryProvider);
    await labelRepo.seedDefaultLabels(userId);
  } catch (e) {
    debugPrint('Default labels seeding notice: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MomentumApp(),
    ),
  );
}
