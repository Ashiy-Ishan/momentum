import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/motivation_service.dart';
import '../domain/motivation_quote.dart';

final motivationServiceProvider = Provider<MotivationService>((ref) {
  return MotivationService();
});

final currentGreetingProvider = Provider<String>((ref) {
  final service = ref.watch(motivationServiceProvider);
  return service.getGreeting();
});

final quoteRefreshTriggerProvider = StateProvider<int>((ref) => 0);

final currentQuoteProvider = FutureProvider<MotivationQuote?>((ref) async {
  ref.watch(quoteRefreshTriggerProvider);
  final service = ref.watch(motivationServiceProvider);
  return service.getQuoteForTimeOfDay();
});

final refreshQuoteProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(quoteRefreshTriggerProvider.notifier).state++;
  };
});

final isMotivationEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(motivationServiceProvider);
  return service.isMotivationEnabled();
});

final completionQuoteProvider = FutureProvider<MotivationQuote?>((ref) async {
  final service = ref.watch(motivationServiceProvider);
  return service.getCompletionQuote();
});
