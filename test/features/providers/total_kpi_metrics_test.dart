import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/constants/default_kpis.dart';
import 'package:momentum/data/local/database.dart';
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/models.dart' as domain;
import 'package:momentum/features/analytics/providers/analytics_providers.dart';
import 'package:momentum/shared/providers/database_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase inMemoryDb;
  late ProviderContainer container;

  setUp(() {
    inMemoryDb = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(inMemoryDb),
        currentUserIdProvider.overrideWith((ref) => 'test-kpi-user'),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await inMemoryDb.close();
  });

  group('TotalKpiMetrics & Provider Tests', () {
    test('computes empty metrics when no KPIs exist', () async {
      final totalsAsync = container.read(totalKpiMetricsProvider);
      final totals = totalsAsync.valueOrNull ?? const TotalKpiMetrics();

      expect(totals.totalKpisCount, equals(0));
      expect(totals.achievedCount, equals(0));
      expect(totals.overallCompletionRate, equals(0.0));
      expect(totals.totalVideosCurrent, equals(0.0));
      expect(totals.totalAudienceCurrent, equals(0.0));
    });

    test('aggregates seeded creator KPIs with correct category outputs', () async {
      final kpiRepo = container.read(kpiRepositoryProvider);
      const userId = 'test-kpi-user';
      final seeded = DefaultKpis.getDefaults(userId);

      for (final k in seeded) {
        await kpiRepo.createKpi(k);
      }

      // Read from stream
      final kpis = await container.read(allKpisStreamProvider.future);
      expect(kpis.length, equals(seeded.length));

      final totals = container.read(totalKpiMetricsProvider).valueOrNull!;
      expect(totals.totalKpisCount, equals(seeded.length));

      // Video Generation targets
      expect(totals.totalVideosTarget, equals(2.0));
      expect(totals.totalShortsTarget, equals(5.0));
      expect(totals.totalVideosLongTerm, equals(50.0));

      // Post Publication targets
      expect(totals.totalPostsTarget, equals(10.0)); // 7 Instagram + 3 LinkedIn

      // Article Publishing targets
      expect(totals.totalArticlesTarget, equals(1.0));
      expect(totals.totalArticlesLongTerm, equals(52.0));

      // Combined Audience Reach (1250 YouTube subs + 3400 IG + 450 blog + 120 github + 850 linkedin = 6070)
      expect(totals.totalAudienceCurrent, equals(6070.0));
      expect(totals.totalAudienceShortTermTarget, greaterThan(0));
      expect(totals.totalAudienceLongTermTarget, greaterThan(20000));
      expect(totals.audienceMetrics.length, equals(5));
      expect(totals.outputMetrics.length, equals(6));
    });

    test('incrementing KPI value updates aggregate velocity reactively', () async {
      final kpiRepo = container.read(kpiRepositoryProvider);
      const userId = 'test-kpi-user';
      final now = DateTime.now();

      final videoKpi = domain.KpiDefinition(
        id: 'kpi-video-test',
        userId: userId,
        name: 'Weekly Video Generation',
        targetValue: 2.0,
        currentValue: 1.0,
        longTermTarget: 50.0,
        unit: 'videos',
        platform: 'youtube',
        metricCategory: 'video_generation',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await kpiRepo.createKpi(videoKpi);
      await container.read(allKpisStreamProvider.future);

      var totals = container.read(totalKpiMetricsProvider).valueOrNull!;
      expect(totals.totalVideosCurrent, equals(1.0));
      expect(totals.achievedCount, equals(0));

      // Increment value to meet target
      await kpiRepo.incrementCurrentValue('kpi-video-test', 1.0);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      totals = container.read(totalKpiMetricsProvider).valueOrNull!;
      expect(totals.totalVideosCurrent, equals(2.0));
      expect(totals.achievedCount, equals(1));
      expect(totals.overallCompletionRate, equals(1.0));
    });
  });
}
