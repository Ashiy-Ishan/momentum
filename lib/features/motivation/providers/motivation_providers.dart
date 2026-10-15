import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/motivation_service.dart';
import '../domain/motivation_quote.dart';

/// Provider exposing the singleton [MotivationService].
final motivationServiceProvider = Provider<MotivationService>((ref) {
  return MotivationService();
});

/// Provider exposing the current time-of-day greeting (e.g., "Good morning").
final currentGreetingProvider = Provider<String>((ref) {
  final service = ref.watch(motivationServiceProvider);
  return service.getGreeting();
});

/// Internal state provider tracking quote refreshes.
final quoteRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// FutureProvider that supplies the currently displayed motivational quote based on time of day.
///
/// Refreshes automatically when [refreshQuoteProvider] is invoked.
/// Returns `null` if the user has disabled motivation quotes.
final currentQuoteProvider = FutureProvider<MotivationQuote?>((ref) async {
  ref.watch(quoteRefreshTriggerProvider);
  final service = ref.watch(motivationServiceProvider);
  return service.getQuoteForTimeOfDay();
});

/// Callback provider used by the UI to refresh the current motivational quote.
///
/// Example usage:
/// ```dart
/// ref.read(refreshQuoteProvider)();
/// ```
final refreshQuoteProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(quoteRefreshTriggerProvider.notifier).state++;
  };
});

/// FutureProvider indicating whether motivational quotes are enabled by the user.
final isMotivationEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(motivationServiceProvider);
  return service.isMotivationEnabled();
});

/// FutureProvider that retrieves a celebratory quote when a task is completed.
final completionQuoteProvider = FutureProvider<MotivationQuote?>((ref) async {
  final service = ref.watch(motivationServiceProvider);
  return service.getCompletionQuote();
});
