import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/core/constants/default_kpis.dart';
import 'package:momentum/data/local/daos/kpi_dao.dart';
import 'package:momentum/data/local/database.dart' as db;
import 'package:momentum/data/repositories/kpi_repository.dart';
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/kpi_definition.dart';
import 'package:momentum/domain/models/label.dart';

void main() {
  group('KpiDefinition Domain Model', () {
    test('Default field values are set correctly', () {
      final now = DateTime.now();
      final kpi = KpiDefinition(
        id: 'kpi_1',
        userId: 'user_1',
        name: 'Weekly Videos',
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(kpi.currentValue, 0.0);
      expect(kpi.longTermTarget, isNull);
      expect(kpi.unit, 'count');
      expect(kpi.platform, 'general');
      expect(kpi.metricCategory, 'output');
      expect(kpi.hasLongTermTarget, isFalse);
      expect(kpi.shortTermProgress, 0.0);
      expect(kpi.longTermProgress, 0.0);
    });

    test('Helper getters compute progress correctly', () {
      final now = DateTime.now();
      final kpi = KpiDefinition(
        id: 'kpi_2',
        userId: 'user_1',
        name: 'YouTube Shorts',
        targetValue: 5.0,
        currentValue: 2.5,
        longTermTarget: 50.0,
        unit: 'shorts',
        platform: 'youtube',
        metricCategory: 'video_generation',
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(kpi.hasLongTermTarget, isTrue);
      expect(kpi.shortTermProgress, 0.5);
      expect(kpi.longTermProgress, 0.05);
    });

    test('Progress clamps at 1.0 when exceeding target', () {
      final now = DateTime.now();
      final kpi = KpiDefinition(
        id: 'kpi_3',
        userId: 'user_1',
        name: 'Daily Posts',
        targetValue: 2.0,
        currentValue: 5.0,
        longTermTarget: 4.0,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(kpi.shortTermProgress, 1.0);
      expect(kpi.longTermProgress, 1.0);
    });

    test('Serialization toMap and fromMap works symmetrically', () {
      final now = DateTime(2026, 10, 15, 12, 0);
      final kpi = KpiDefinition(
        id: 'kpi_subscribers',
        userId: 'user_creator',
        labelId: 'label_youtube',
        name: 'Channel Subscribers',
        description: 'Subscriber milestone target',
        kpiType: KpiType.count,
        targetValue: 50.0,
        currentValue: 1250.0,
        longTermTarget: 10000.0,
        unit: 'subs',
        platform: 'youtube',
        metricCategory: 'subscriber_growth',
        period: KpiPeriod.monthly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = kpi.toMap();
      expect(map['currentValue'], 1250.0);
      expect(map['longTermTarget'], 10000.0);
      expect(map['unit'], 'subs');
      expect(map['platform'], 'youtube');
      expect(map['metricCategory'], 'subscriber_growth');

      final reconstructed = KpiDefinition.fromMap(map);
      expect(reconstructed.id, kpi.id);
      expect(reconstructed.currentValue, 1250.0);
      expect(reconstructed.longTermTarget, 10000.0);
      expect(reconstructed.unit, 'subs');
      expect(reconstructed.platform, 'youtube');
      expect(reconstructed.metricCategory, 'subscriber_growth');
      expect(reconstructed.hasLongTermTarget, isTrue);
    });

    test('copyWith modifies expanded KPI fields accurately', () {
      final now = DateTime.now();
      final kpi = KpiDefinition(
        id: 'kpi_test',
        userId: 'user_1',
        name: 'Original',
        targetValue: 10.0,
        currentValue: 2.0,
        longTermTarget: 100.0,
        unit: 'videos',
        platform: 'youtube',
        metricCategory: 'video_generation',
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final updated = kpi.copyWith(
        currentValue: 6.0,
        unit: 'articles',
        platform: 'blog',
        metricCategory: 'blog_publication',
        clearLongTermTarget: true,
      );

      expect(updated.currentValue, 6.0);
      expect(updated.unit, 'articles');
      expect(updated.platform, 'blog');
      expect(updated.metricCategory, 'blog_publication');
      expect(updated.longTermTarget, isNull);
      expect(updated.hasLongTermTarget, isFalse);
    });
  });

  group('DefaultKpis Constants', () {
    test('Provides all 11 default platform creator & developer KPIs', () {
      final kpis = DefaultKpis.getDefaults('user_123');
      expect(kpis.length, 11);

      final weeklyVideos = kpis.firstWhere((k) => k.name == 'Weekly Video Generation');
      expect(weeklyVideos.targetValue, 2.0);
      expect(weeklyVideos.unit, 'videos');
      expect(weeklyVideos.metricCategory, 'video_generation');
      expect(weeklyVideos.longTermTarget, 50.0);
      expect(weeklyVideos.platform, 'youtube');
      expect(weeklyVideos.period, KpiPeriod.weekly);

      final shortsVelocity = kpis.firstWhere((k) => k.name == 'YouTube Shorts Velocity');
      expect(shortsVelocity.targetValue, 5.0);
      expect(shortsVelocity.unit, 'shorts');
      expect(shortsVelocity.metricCategory, 'video_generation');
      expect(shortsVelocity.longTermTarget, 100.0);
      expect(shortsVelocity.platform, 'youtube');

      final subs = kpis.firstWhere((k) => k.name == 'Channel Subscribers');
      expect(subs.currentValue, 0.0);
      expect(subs.targetValue, 2500.0);
      expect(subs.unit, 'subs');
      expect(subs.metricCategory, 'subscriber_growth');
      expect(subs.longTermTarget, 10000.0);
      expect(subs.period, KpiPeriod.monthly);
      expect(subs.platform, 'youtube');

      final posts = kpis.firstWhere((k) => k.name == 'Weekly Post Publication');
      expect(posts.targetValue, 7.0);
      expect(posts.unit, 'posts');
      expect(posts.metricCategory, 'post_publication');
      expect(posts.longTermTarget, 365.0);
      expect(posts.platform, 'instagram');
      expect(posts.period, KpiPeriod.weekly);

      final followers = kpis.firstWhere((k) => k.name == 'Audience & Followers');
      expect(followers.currentValue, 0.0);
      expect(followers.targetValue, 5000.0);
      expect(followers.unit, 'followers');
      expect(followers.metricCategory, 'follower_growth');
      expect(followers.longTermTarget, 10000.0);
      expect(followers.period, KpiPeriod.monthly);
      expect(followers.platform, 'instagram');

      final ghCommits = kpis.firstWhere((k) => k.name == 'Weekly Commits & PRs');
      expect(ghCommits.targetValue, 10.0);
      expect(ghCommits.unit, 'commits');
      expect(ghCommits.metricCategory, 'output');
      expect(ghCommits.platform, 'github');

      final ghStars = kpis.firstWhere((k) => k.name == 'GitHub Stars & Followers');
      expect(ghStars.currentValue, 0.0);
      expect(ghStars.targetValue, 500.0);
      expect(ghStars.unit, 'stars');
      expect(ghStars.platform, 'github');

      final linkedinPosts = kpis.firstWhere((k) => k.name == 'Weekly LinkedIn Insights');
      expect(linkedinPosts.targetValue, 3.0);
      expect(linkedinPosts.unit, 'posts');
      expect(linkedinPosts.platform, 'linkedin');

      final linkedinConn = kpis.firstWhere((k) => k.name == 'LinkedIn Connections');
      expect(linkedinConn.currentValue, 0.0);
      expect(linkedinConn.targetValue, 2500.0);
      expect(linkedinConn.unit, 'connections');
      expect(linkedinConn.platform, 'linkedin');

      final blogs = kpis.firstWhere((k) => k.name == 'Weekly Blog Publication');
      expect(blogs.targetValue, 1.0);
      expect(blogs.unit, 'articles');
      expect(blogs.metricCategory, 'blog_publication');
      expect(blogs.longTermTarget, 52.0);
      expect(blogs.platform, 'blog');
      expect(blogs.period, KpiPeriod.weekly);

      final readers = kpis.firstWhere((k) => k.name == 'Newsletter Readers');
      expect(readers.currentValue, 0.0);
      expect(readers.targetValue, 1000.0);
      expect(readers.unit, 'readers');
      expect(readers.metricCategory, 'subscriber_growth');
      expect(readers.longTermTarget, 2500.0);
      expect(readers.period, KpiPeriod.monthly);
      expect(readers.platform, 'blog');
    });

    test('Associates matching labelId when provided in labels list', () {
      final now = DateTime.now();
      final labels = [
        Label(
          id: 'lbl_yt',
          userId: 'user_abc',
          name: 'YouTube',
          iconName: 'videocam',
          color: '#FF0000',
          createdAt: now,
          updatedAt: now,
        ),
        Label(
          id: 'lbl_ig',
          userId: 'user_abc',
          name: 'Instagram',
          iconName: 'camera',
          color: '#E1306C',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final kpis = DefaultKpis.getDefaults('user_abc', labels: labels);
      final ytKpi = kpis.firstWhere((k) => k.platform == 'youtube');
      final igKpi = kpis.firstWhere((k) => k.platform == 'instagram');

      expect(ytKpi.labelId, 'lbl_yt');
      expect(igKpi.labelId, 'lbl_ig');
    });
  });

  group('KpiRepository & Database Integration', () {
    late db.AppDatabase database;
    late KpiDao kpiDao;
    late KpiRepository kpiRepo;

    setUp(() {
      database = db.AppDatabase.forTesting(NativeDatabase.memory());
      kpiDao = KpiDao(database);
      kpiRepo = KpiRepositoryImpl(database: database, kpiDao: kpiDao);
    });

    tearDown(() async {
      await database.close();
    });

    test('seedDefaultPlatformKpis inserts all default KPIs for user', () async {
      const userId = 'creator_user_1';
      await kpiRepo.seedDefaultPlatformKpis(userId, []);

      final stored = await kpiRepo.getAllKpis(userId);
      expect(stored.length, 11);

      final ytSub = stored.firstWhere((k) => k.name == 'Channel Subscribers');
      expect(ytSub.currentValue, 0.0);
      expect(ytSub.longTermTarget, 10000.0);
      expect(ytSub.unit, 'subs');
      expect(ytSub.platform, 'youtube');
      expect(ytSub.metricCategory, 'subscriber_growth');
    });

    test('updateCurrentValue and incrementCurrentValue modify stored KPI value', () async {
      const userId = 'creator_user_2';
      await kpiRepo.seedDefaultPlatformKpis(userId, []);

      final initial = await kpiRepo.getAllKpis(userId);
      final ytVideos = initial.firstWhere((k) => k.name == 'Weekly Video Generation');

      await kpiRepo.updateCurrentValue(ytVideos.id, 1.0);
      var updated = await kpiRepo.getAllKpis(userId);
      var current = updated.firstWhere((k) => k.id == ytVideos.id);
      expect(current.currentValue, 1.0);

      await kpiRepo.incrementCurrentValue(ytVideos.id, 2.0);
      updated = await kpiRepo.getAllKpis(userId);
      current = updated.firstWhere((k) => k.id == ytVideos.id);
      expect(current.currentValue, 3.0);
    });
  });
}
