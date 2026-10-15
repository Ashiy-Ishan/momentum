import '../../domain/enums/enums.dart';
import '../../domain/models/kpi_definition.dart';
import '../../domain/models/label.dart';

/// Pre-seeded creator KPI definitions for platforms (YouTube, Instagram/Social Media, Blog).
abstract class DefaultKpis {
  /// Generates the standard platform and output KPI definitions for a user.
  ///
  /// Optionally associates KPIs with matching domain [labels] if available.
  static List<KpiDefinition> getDefaults(
    String userId, {
    List<Label> labels = const [],
  }) {
    final now = DateTime.now();

    // Resolve matching label IDs if available in the labels list
    String? findLabelId(bool Function(Label l) predicate) {
      try {
        return labels.firstWhere(predicate).id;
      } catch (_) {
        return null;
      }
    }

    final youtubeLabelId = findLabelId(
      (l) =>
          !l.isDeleted &&
          (l.name.toLowerCase() == 'youtube' ||
              l.id.toLowerCase().contains('youtube')),
    );

    final instagramLabelId = findLabelId(
      (l) =>
          !l.isDeleted &&
          (l.name.toLowerCase() == 'instagram' ||
              l.id.toLowerCase().contains('instagram')),
    ) ?? findLabelId(
      (l) =>
          !l.isDeleted &&
          (l.name.toLowerCase().contains('social') ||
              l.id.toLowerCase().contains('social')),
    );

    final blogLabelId = findLabelId(
      (l) =>
          !l.isDeleted &&
          (l.name.toLowerCase().contains('blog') ||
              l.name.toLowerCase().contains('writing') ||
              l.name.toLowerCase().contains('projects')),
    );

    final githubLabelId = findLabelId(
      (l) =>
          !l.isDeleted &&
          (l.name.toLowerCase().contains('programming') ||
              l.name.toLowerCase().contains('linux') ||
              l.name.toLowerCase().contains('learning')),
    );

    final linkedinLabelId = findLabelId(
      (l) =>
          !l.isDeleted &&
          (l.name.toLowerCase().contains('career') ||
              l.name.toLowerCase().contains('internship') ||
              l.name.toLowerCase().contains('portfolio')),
    );

    return [
      // -----------------------------------------------------------------------
      // 1. YouTube: Weekly Video Generation
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_youtube_weekly_videos',
        userId: userId,
        labelId: youtubeLabelId,
        name: 'Weekly Video Generation',
        description: 'Publish full-length polished videos to YouTube each week.',
        kpiType: KpiType.count,
        targetValue: 2.0,
        currentValue: 0.0,
        longTermTarget: 50.0,
        unit: 'videos',
        platform: 'youtube',
        metricCategory: 'video_generation',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 2. YouTube: YouTube Shorts Velocity
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_youtube_shorts_velocity',
        userId: userId,
        labelId: youtubeLabelId,
        name: 'YouTube Shorts Velocity',
        description: 'Short-form video output velocity to reach broader discoverability.',
        kpiType: KpiType.count,
        targetValue: 5.0,
        currentValue: 0.0,
        longTermTarget: 100.0,
        unit: 'shorts',
        platform: 'youtube',
        metricCategory: 'video_generation',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 3. YouTube: Channel Subscribers
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_youtube_subscribers',
        userId: userId,
        labelId: youtubeLabelId,
        name: 'Channel Subscribers',
        description: 'Track YouTube channel subscriber growth against long-term milestone.',
        kpiType: KpiType.count,
        targetValue: 2500.0,
        currentValue: 1250.0,
        longTermTarget: 10000.0,
        unit: 'subs',
        platform: 'youtube',
        metricCategory: 'subscriber_growth',
        period: KpiPeriod.monthly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 4. Social Media / Instagram: Weekly Post Publication
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_instagram_weekly_posts',
        userId: userId,
        labelId: instagramLabelId,
        name: 'Weekly Post Publication',
        description: 'Maintain consistent social media engagement and daily/weekly post cadence.',
        kpiType: KpiType.count,
        targetValue: 7.0,
        currentValue: 0.0,
        longTermTarget: 365.0,
        unit: 'posts',
        platform: 'instagram',
        metricCategory: 'post_publication',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 5. Social Media / Instagram: Audience & Followers
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_instagram_followers',
        userId: userId,
        labelId: instagramLabelId,
        name: 'Audience & Followers',
        description: 'Instagram/Social media community reach and follower base growth.',
        kpiType: KpiType.count,
        targetValue: 5000.0,
        currentValue: 3400.0,
        longTermTarget: 10000.0,
        unit: 'followers',
        platform: 'instagram',
        metricCategory: 'follower_growth',
        period: KpiPeriod.monthly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 6. Blog / Technical Writing: Weekly Blog Publication
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_blog_weekly_publication',
        userId: userId,
        labelId: blogLabelId,
        name: 'Weekly Blog Publication',
        description: 'Publish in-depth technical blogs and research essays regularly.',
        kpiType: KpiType.count,
        targetValue: 1.0,
        currentValue: 0.0,
        longTermTarget: 52.0,
        unit: 'articles',
        platform: 'blog',
        metricCategory: 'blog_publication',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 7. Blog: Newsletter Readers
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_blog_newsletter_readers',
        userId: userId,
        labelId: blogLabelId,
        name: 'Newsletter Readers',
        description: 'Subscribers and active readers engaged with written newsletter issues.',
        kpiType: KpiType.count,
        targetValue: 1000.0,
        currentValue: 450.0,
        longTermTarget: 2500.0,
        unit: 'readers',
        platform: 'blog',
        metricCategory: 'subscriber_growth',
        period: KpiPeriod.monthly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 8. GitHub: Weekly Code Commits & PRs
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_github_weekly_commits',
        userId: userId,
        labelId: githubLabelId,
        name: 'Weekly Commits & PRs',
        description: 'Maintain engineering velocity with weekly commits and shipped PRs.',
        kpiType: KpiType.count,
        targetValue: 10.0,
        currentValue: 0.0,
        longTermTarget: 500.0,
        unit: 'commits',
        platform: 'github',
        metricCategory: 'output',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 9. GitHub: Stars & Followers
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_github_followers',
        userId: userId,
        labelId: githubLabelId,
        name: 'GitHub Stars & Followers',
        description: 'Developer community engagement and repository stars growth.',
        kpiType: KpiType.count,
        targetValue: 500.0,
        currentValue: 120.0,
        longTermTarget: 1000.0,
        unit: 'stars',
        platform: 'github',
        metricCategory: 'follower_growth',
        period: KpiPeriod.monthly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 10. LinkedIn: Weekly Insights
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_linkedin_weekly_posts',
        userId: userId,
        labelId: linkedinLabelId,
        name: 'Weekly LinkedIn Insights',
        description: 'Publish industry insights, software case studies, and career updates.',
        kpiType: KpiType.count,
        targetValue: 3.0,
        currentValue: 0.0,
        longTermTarget: 150.0,
        unit: 'posts',
        platform: 'linkedin',
        metricCategory: 'post_publication',
        period: KpiPeriod.weekly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),

      // -----------------------------------------------------------------------
      // 11. LinkedIn: Professional Network Connections
      // -----------------------------------------------------------------------
      KpiDefinition(
        id: 'kpi_${userId}_linkedin_connections',
        userId: userId,
        labelId: linkedinLabelId,
        name: 'LinkedIn Connections',
        description: 'Grow high-value professional connections and industry peers.',
        kpiType: KpiType.count,
        targetValue: 2500.0,
        currentValue: 850.0,
        longTermTarget: 5000.0,
        unit: 'connections',
        platform: 'linkedin',
        metricCategory: 'follower_growth',
        period: KpiPeriod.monthly,
        startDate: now,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
