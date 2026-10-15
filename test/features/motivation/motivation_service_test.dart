import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/features/motivation/data/motivation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAssetBundle extends CachingAssetBundle {
  final String _content;
  MockAssetBundle(this._content);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _content;
  }

  @override
  Future<ByteData> load(String key) async {
    final list = utf8.encode(_content);
    return ByteData.view(Uint8List.fromList(list).buffer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mockQuotesJson = '''
{
  "quotes": [
    {
      "text": "Morning focus brings clarity.",
      "author": "Author A",
      "category": "morning"
    },
    {
      "text": "Start the dawn with intent.",
      "author": null,
      "category": "morning"
    },
    {
      "text": "Midday resilience wins.",
      "author": "Author B",
      "category": "afternoon"
    },
    {
      "text": "Evening rest restores power.",
      "author": "Author C",
      "category": "evening"
    },
    {
      "text": "Task finished! Well done.",
      "author": null,
      "category": "completion"
    },
    {
      "text": "General wisdom for all times.",
      "author": "Author D",
      "category": "general"
    }
  ]
}
''';

  group('MotivationService', () {
    late MotivationService service;
    late MockAssetBundle mockBundle;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockBundle = MockAssetBundle(mockQuotesJson);
      service = MotivationService(assetBundle: mockBundle);
    });

    group('Time-of-day greetings', () {
      test('returns "Good morning" between 05:00 and 11:59', () {
        expect(service.getGreeting(DateTime(2026, 10, 16, 5, 0)), 'Good morning');
        expect(service.getGreeting(DateTime(2026, 10, 16, 9, 30)), 'Good morning');
        expect(service.getGreeting(DateTime(2026, 10, 16, 11, 59)), 'Good morning');
      });

      test('returns "Good afternoon" between 12:00 and 16:59', () {
        expect(service.getGreeting(DateTime(2026, 10, 16, 12, 0)), 'Good afternoon');
        expect(service.getGreeting(DateTime(2026, 10, 16, 14, 15)), 'Good afternoon');
        expect(service.getGreeting(DateTime(2026, 10, 16, 16, 59)), 'Good afternoon');
      });

      test('returns "Good evening" between 17:00 and 04:59', () {
        expect(service.getGreeting(DateTime(2026, 10, 16, 17, 0)), 'Good evening');
        expect(service.getGreeting(DateTime(2026, 10, 16, 21, 0)), 'Good evening');
        expect(service.getGreeting(DateTime(2026, 10, 16, 23, 59)), 'Good evening');
        expect(service.getGreeting(DateTime(2026, 10, 16, 4, 30)), 'Good evening');
      });
    });

    group('Time-of-day quote categories', () {
      test('correctly maps time of day to quote category', () {
        expect(service.getTimeOfDayCategory(DateTime(2026, 10, 16, 8, 0)), 'morning');
        expect(service.getTimeOfDayCategory(DateTime(2026, 10, 16, 13, 0)), 'afternoon');
        expect(service.getTimeOfDayCategory(DateTime(2026, 10, 16, 20, 0)), 'evening');
      });
    });

    group('Loading quotes and caching', () {
      test('loads all quotes from bundle and caches them', () async {
        final quotes = await service.loadQuotes();
        expect(quotes.length, 6);
        expect(quotes.first.text, 'Morning focus brings clarity.');
        expect(quotes.first.author, 'Author A');
        expect(quotes.first.category, 'morning');

        // Subsequent call uses cache
        final cached = await service.loadQuotes();
        expect(identical(quotes, cached), isTrue);
      });

      test('retrieves completion quote', () async {
        final quote = await service.getCompletionQuote();
        expect(quote, isNotNull);
        expect(quote!.category, 'completion');
        expect(quote.text, 'Task finished! Well done.');
      });

      test('retrieves quote appropriate for morning', () async {
        final morningTime = DateTime(2026, 10, 16, 9, 0);
        final quote = await service.getQuoteForTimeOfDay(morningTime);
        expect(quote, isNotNull);
        expect(quote!.category, 'morning');
      });
    });

    group('Anti-repetition algorithm', () {
      test('avoids repeating the same quote consecutively when choices exist', () async {
        final morningTime = DateTime(2026, 10, 16, 9, 0);
        final firstQuote = await service.getQuoteForTimeOfDay(morningTime);
        final secondQuote = await service.getQuoteForTimeOfDay(morningTime);

        expect(firstQuote, isNotNull);
        expect(secondQuote, isNotNull);
        // There are 2 morning quotes, so the second call must pick the other one
        expect(firstQuote!.text, isNot(equals(secondQuote!.text)));
      });
    });

    group('User enable/disable toggle', () {
      test('returns null when motivation quotes are disabled', () async {
        expect(await service.isMotivationEnabled(), isTrue);

        await service.setMotivationEnabled(false);
        expect(await service.isMotivationEnabled(), isFalse);

        final quote = await service.getQuoteForTimeOfDay();
        expect(quote, isNull);

        final completion = await service.getCompletionQuote();
        expect(completion, isNull);

        // Re-enabling returns quotes again
        await service.setMotivationEnabled(true);
        expect(await service.isMotivationEnabled(), isTrue);

        final quoteAfterEnable = await service.getQuoteForTimeOfDay();
        expect(quoteAfterEnable, isNotNull);
      });
    });
  });
}
