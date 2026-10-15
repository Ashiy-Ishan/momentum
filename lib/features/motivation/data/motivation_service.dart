import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/motivation_quote.dart';

/// Service responsible for loading, caching, and serving motivational quotes and greetings.
///
/// Features:
/// - Loads quotes from `assets/quotes.json`
/// - In-memory caching for zero-latency retrieval
/// - Time-of-day greeting and category alignment
/// - Anti-repetition algorithm tracking recently displayed quotes
/// - Toggle user preferences for enabling or disabling motivation quotes
class MotivationService {
  MotivationService({
    this.prefs,
    AssetBundle? assetBundle,
  })  : _assetBundle = assetBundle ?? rootBundle;

  static const String _prefMotivationEnabled = 'momentum_motivation_enabled';
  static const String _prefRecentQuotes = 'momentum_recent_quote_history';
  static const int _maxRecentHistory = 15;

  SharedPreferences? prefs;
  final AssetBundle _assetBundle;
  final Random _random = Random();

  List<MotivationQuote>? _cachedQuotes;
  final Map<String, List<MotivationQuote>> _quotesByCategory = {};
  final List<String> _recentlyShownTexts = [];
  bool? _cachedEnabled;

  /// Retrieves the time-of-day greeting.
  ///
  /// - Morning: 05:00 - 11:59 ("Good morning")
  /// - Afternoon: 12:00 - 16:59 ("Good afternoon")
  /// - Evening / Night: 17:00 - 04:59 ("Good evening")
  String getGreeting([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Determines the relevant quote category based on current time.
  String getTimeOfDayCategory([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  /// Checks if motivational quotes are enabled by the user. Defaults to `true`.
  Future<bool> isMotivationEnabled() async {
    if (_cachedEnabled != null) return _cachedEnabled!;
    try {
      prefs ??= await SharedPreferences.getInstance();
      _cachedEnabled = prefs?.getBool(_prefMotivationEnabled) ?? true;
    } catch (_) {
      _cachedEnabled = true;
    }
    return _cachedEnabled!;
  }

  /// Enables or disables motivational quotes according to user preference.
  Future<void> setMotivationEnabled(bool enabled) async {
    _cachedEnabled = enabled;
    try {
      prefs ??= await SharedPreferences.getInstance();
      await prefs?.setBool(_prefMotivationEnabled, enabled);
    } catch (e) {
      debugPrint('MotivationService: Failed to persist motivation preference: $e');
    }
  }

  /// Loads all motivational quotes from `assets/quotes.json` and caches them locally.
  Future<List<MotivationQuote>> loadQuotes() async {
    if (_cachedQuotes != null && _cachedQuotes!.isNotEmpty) {
      return _cachedQuotes!;
    }

    try {
      final jsonString =
          await _assetBundle.loadString('assets/quotes.json');
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final rawQuotes = data['quotes'] as List<dynamic>? ?? [];
      final List<MotivationQuote> parsed = [];
      _quotesByCategory.clear();

      for (final item in rawQuotes) {
        if (item is Map<String, dynamic>) {
          final quote = MotivationQuote.fromMap(item);
          if (quote.text.isNotEmpty) {
            parsed.add(quote);
            _quotesByCategory
                .putIfAbsent(quote.category.toLowerCase(), () => [])
                .add(quote);
          }
        }
      }

      _cachedQuotes = parsed;
      await _loadRecentHistory();
      return _cachedQuotes!;
    } catch (e, st) {
      debugPrint('MotivationService: Failed to load quotes from asset: $e\n$st');
      return const [];
    }
  }

  /// Returns an appropriate quote based on the current time of day (morning, afternoon, evening).
  ///
  /// Returns `null` if the user has disabled motivational quotes or if no quotes are available.
  Future<MotivationQuote?> getQuoteForTimeOfDay([DateTime? dateTime]) async {
    final enabled = await isMotivationEnabled();
    if (!enabled) return null;

    final category = getTimeOfDayCategory(dateTime);
    return _pickQuoteWithAntiRepetition(preferredCategory: category);
  }

  /// Returns a celebratory quote specifically for task or milestone completion.
  ///
  /// Returns `null` if motivation is disabled.
  Future<MotivationQuote?> getCompletionQuote() async {
    final enabled = await isMotivationEnabled();
    if (!enabled) return null;

    return _pickQuoteWithAntiRepetition(preferredCategory: 'completion');
  }

  /// Returns a random quote for a given category (or across all categories).
  Future<MotivationQuote?> getRandomQuote({String? category}) async {
    final enabled = await isMotivationEnabled();
    if (!enabled) return null;

    return _pickQuoteWithAntiRepetition(preferredCategory: category);
  }

  /// Core quote selection algorithm with anti-repetition filter.
  Future<MotivationQuote?> _pickQuoteWithAntiRepetition({
    String? preferredCategory,
  }) async {
    final allQuotes = await loadQuotes();
    if (allQuotes.isEmpty) return null;

    List<MotivationQuote> candidates = [];

    // 1. Try to find candidates in preferred category
    if (preferredCategory != null && preferredCategory.isNotEmpty) {
      candidates = _quotesByCategory[preferredCategory.toLowerCase()] ?? [];
    }

    // 2. If no candidates found, fallback to 'general'
    if (candidates.isEmpty) {
      candidates = _quotesByCategory['general'] ?? [];
    }

    // 3. If still empty, use all quotes
    if (candidates.isEmpty) {
      candidates = allQuotes;
    }

    // 4. Filter out recently shown quotes to prevent frequent repetition
    List<MotivationQuote> eligible = candidates
        .where((q) => !_recentlyShownTexts.contains(q.text))
        .toList();

    // 5. If all candidates were recently shown, clear category entries from recent list
    if (eligible.isEmpty) {
      final candidateTexts = candidates.map((c) => c.text).toSet();
      _recentlyShownTexts.removeWhere((t) => candidateTexts.contains(t));
      eligible = candidates;
    }

    // 6. Pick random candidate
    final selectedIndex = _random.nextInt(eligible.length);
    final selectedQuote = eligible[selectedIndex];

    // 7. Track in recent history
    _recordShownQuote(selectedQuote.text);

    return selectedQuote;
  }

  void _recordShownQuote(String text) {
    _recentlyShownTexts.remove(text);
    _recentlyShownTexts.add(text);
    if (_recentlyShownTexts.length > _maxRecentHistory) {
      _recentlyShownTexts.removeAt(0);
    }
    _saveRecentHistory();
  }

  Future<void> _loadRecentHistory() async {
    try {
      prefs ??= await SharedPreferences.getInstance();
      final list = prefs?.getStringList(_prefRecentQuotes);
      if (list != null && list.isNotEmpty) {
        _recentlyShownTexts.clear();
        _recentlyShownTexts.addAll(list);
      }
    } catch (_) {}
  }

  Future<void> _saveRecentHistory() async {
    try {
      prefs ??= await SharedPreferences.getInstance();
      await prefs?.setStringList(_prefRecentQuotes, _recentlyShownTexts);
    } catch (_) {}
  }
}
