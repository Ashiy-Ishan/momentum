import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/domain/enums/enums.dart';
import 'package:momentum/domain/models/models.dart';
import 'package:momentum/domain/services/services.dart';

void main() {
  group('RecurrenceEngine', () {
    const engine = RecurrenceEngine();
    final now = DateTime(2026, 10, 15);

    test('RecurrenceType.once only matches start date', () {
      final rule = RecurrenceRule(
        id: 'r1',
        userId: 'u1',
        type: RecurrenceType.once,
        startDate: DateTime(2026, 10, 15, 14, 30),
        createdAt: now,
        updatedAt: now,
      );

      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 15, 8, 0)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 14)), isFalse);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 16)), isFalse);

      final occ = engine.generateOccurrences(
        rule,
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 31),
      );
      expect(occ.length, 1);
      expect(occ.first, DateTime(2026, 10, 15));
    });

    test('RecurrenceType.daily matches every day and respects intervalDays', () {
      final rule = RecurrenceRule(
        id: 'r2',
        userId: 'u1',
        type: RecurrenceType.daily,
        intervalDays: 2, // every 2 days
        startDate: DateTime(2026, 10, 1),
        createdAt: now,
        updatedAt: now,
      );

      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 1)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 2)), isFalse);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 3)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 4)), isFalse);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 5)), isTrue);

      final occ = engine.generateOccurrences(
        rule,
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 7),
      );
      // 1st, 3rd, 5th, 7th = 4 occurrences
      expect(occ.length, 4);
      expect(occ[0], DateTime(2026, 10, 1));
      expect(occ[1], DateTime(2026, 10, 3));
      expect(occ[2], DateTime(2026, 10, 5));
      expect(occ[3], DateTime(2026, 10, 7));
    });

    test('RecurrenceType.weekdays matches only Monday to Friday', () {
      // 2026-10-15 is Thursday, 16 is Friday, 17 is Saturday, 18 is Sunday, 19 is Monday
      final rule = RecurrenceRule(
        id: 'r3',
        userId: 'u1',
        type: RecurrenceType.weekdays,
        startDate: DateTime(2026, 10, 15),
        createdAt: now,
        updatedAt: now,
      );

      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 15)), isTrue); // Thursday
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 16)), isTrue); // Friday
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 17)), isFalse); // Saturday
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 18)), isFalse); // Sunday
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 19)), isTrue); // Monday
    });

    test('RecurrenceType.everyOtherDay matches every 2 days', () {
      final rule = RecurrenceRule(
        id: 'r4',
        userId: 'u1',
        type: RecurrenceType.everyOtherDay,
        startDate: DateTime(2026, 10, 10),
        createdAt: now,
        updatedAt: now,
      );

      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 10)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 11)), isFalse);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 12)), isTrue);
    });

    test('RecurrenceType.weekly respects daysOfWeek', () {
      // Mon (1), Wed (3), Fri (5)
      final rule = RecurrenceRule(
        id: 'r5',
        userId: 'u1',
        type: RecurrenceType.weekly,
        daysOfWeek: const [1, 3, 5],
        startDate: DateTime(2026, 10, 12), // Monday
        createdAt: now,
        updatedAt: now,
      );

      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 12)), isTrue); // Mon
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 13)), isFalse); // Tue
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 14)), isTrue); // Wed
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 15)), isFalse); // Thu
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 16)), isTrue); // Fri
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 17)), isFalse); // Sat
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 18)), isFalse); // Sun
    });

    test('RecurrenceType.monthly respects intervalMonths and clamps day for shorter months', () {
      // Started on Jan 31, 2026
      final rule = RecurrenceRule(
        id: 'r6',
        userId: 'u1',
        type: RecurrenceType.monthly,
        intervalMonths: 1,
        startDate: DateTime(2026, 1, 31),
        createdAt: now,
        updatedAt: now,
      );

      expect(engine.isScheduledFor(rule, DateTime(2026, 1, 31)), isTrue);
      // Feb 2026 has 28 days -> Feb 28 should match
      expect(engine.isScheduledFor(rule, DateTime(2026, 2, 28)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 2, 27)), isFalse);
      // March has 31 days -> March 31 should match
      expect(engine.isScheduledFor(rule, DateTime(2026, 3, 31)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 3, 30)), isFalse);
      // April has 30 days -> April 30 should match
      expect(engine.isScheduledFor(rule, DateTime(2026, 4, 30)), isTrue);
    });

    test('RecurrenceEngine respects endDate and maxOccurrences', () {
      final rule = RecurrenceRule(
        id: 'r7',
        userId: 'u1',
        type: RecurrenceType.daily,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 10),
        maxOccurrences: 5,
        createdAt: now,
        updatedAt: now,
      );

      // Days 1 to 5 match, day 6 does not because maxOccurrences is 5
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 1)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 5)), isTrue);
      expect(engine.isScheduledFor(rule, DateTime(2026, 10, 6)), isFalse);

      final occ = engine.generateOccurrences(
        rule,
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 31),
      );
      expect(occ.length, 5);
      expect(occ.last, DateTime(2026, 10, 5));
    });

    test('RecurrenceEngine clamps generation to maxDaysWindow', () {
      final rule = RecurrenceRule(
        id: 'r8',
        userId: 'u1',
        type: RecurrenceType.daily,
        startDate: DateTime(2026, 1, 1),
        createdAt: now,
        updatedAt: now,
      );

      // Request 1000 days, but maxDaysWindow is 10
      final occ = engine.generateOccurrences(
        rule,
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 1).add(const Duration(days: 1000)),
        maxDaysWindow: 10,
      );
      // 10 days window inclusive = 11 occurrences (days 0..10)
      expect(occ.length, 11);
    });
  });

  group('KpiService', () {
    const kpiService = KpiService();
    final now = DateTime(2026, 10, 15);

    test('Completion rate calculation handles standard completed/pending ratio', () {
      final today = DateTime(2026, 10, 15);
      final occurrences = [
        TaskOccurrence(
          id: 'o1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.done,
          createdAt: today,
          updatedAt: today,
        ),
        TaskOccurrence(
          id: 'o2',
          userId: 'u1',
          taskId: 't2',
          occurrenceDate: today,
          status: TaskStatus.pending,
          createdAt: today,
          updatedAt: today,
        ),
      ];

      final result = kpiService.calculateDailyCompletionRate(
        occurrences: occurrences,
        date: today,
        asOfDate: today,
      );

      expect(result.eligibleCount, 2);
      expect(result.completedCount, 1);
      expect(result.completionRate, 50.0);
    });

    test('Completion rate excludes cancelled and skipped by default', () {
      final today = DateTime(2026, 10, 15);
      final occurrences = [
        TaskOccurrence(
          id: 'o1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.done,
          createdAt: today,
          updatedAt: today,
        ),
        TaskOccurrence(
          id: 'o2',
          userId: 'u1',
          taskId: 't2',
          occurrenceDate: today,
          status: TaskStatus.cancelled,
          createdAt: today,
          updatedAt: today,
        ),
        TaskOccurrence(
          id: 'o3',
          userId: 'u1',
          taskId: 't3',
          occurrenceDate: today,
          status: TaskStatus.skipped,
          createdAt: today,
          updatedAt: today,
        ),
      ];

      // Default: skipped excluded
      final result = kpiService.calculateDailyCompletionRate(
        occurrences: occurrences,
        date: today,
        asOfDate: today,
        includeSkipped: false,
      );
      expect(result.eligibleCount, 1);
      expect(result.completedCount, 1);
      expect(result.cancelledCount, 1);
      expect(result.skippedCount, 1);
      expect(result.completionRate, 100.0);

      // When includeSkipped = true
      final withSkipped = kpiService.calculateDailyCompletionRate(
        occurrences: occurrences,
        date: today,
        asOfDate: today,
        includeSkipped: true,
      );
      expect(withSkipped.eligibleCount, 2);
      expect(withSkipped.completedCount, 1);
      expect(withSkipped.completionRate, 50.0);
    });

    test('Future incomplete tasks are NOT counted as failures', () {
      final today = DateTime(2026, 10, 15);
      final tomorrow = DateTime(2026, 10, 16);

      final occurrences = [
        TaskOccurrence(
          id: 'o1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.done,
          createdAt: today,
          updatedAt: today,
        ),
        TaskOccurrence(
          id: 'o2',
          userId: 'u1',
          taskId: 't2',
          occurrenceDate: tomorrow,
          status: TaskStatus.pending, // Future pending task
          createdAt: today,
          updatedAt: today,
        ),
      ];

      final result = kpiService.calculateWeeklyCompletionRate(
        occurrences: occurrences,
        weekDate: today,
        asOfDate: today,
      );

      expect(result.eligibleCount, 1);
      expect(result.completedCount, 1);
      expect(result.futureExcludedCount, 1);
      expect(result.completionRate, 100.0);
    });

    test('Zero eligible occurrences returns 0.0 or configurable fallback', () {
      final result = kpiService.calculateCompletionRate(
        occurrences: const [],
        fallbackWhenZeroEligible: 0.0,
      );
      expect(result.completionRate, 0.0);

      final resultFallback = kpiService.calculateCompletionRate(
        occurrences: const [],
        fallbackWhenZeroEligible: 100.0,
      );
      expect(resultFallback.completionRate, 100.0);
    });

    test('Parent-label KPI aggregation accurately sums child and direct metrics without double counting', () {
      final parentLabel = Label(
        id: 'l_parent',
        userId: 'u1',
        name: 'Work',
        iconName: 'work',
        color: '#FF0000',
        createdAt: now,
        updatedAt: now,
      );

      final childLabel1 = Label(
        id: 'l_child1',
        userId: 'u1',
        parentId: 'l_parent',
        name: 'Coding',
        iconName: 'code',
        color: '#00FF00',
        createdAt: now,
        updatedAt: now,
      );

      final childLabel2 = Label(
        id: 'l_child2',
        userId: 'u1',
        parentId: 'l_parent',
        name: 'Meetings',
        iconName: 'meet',
        color: '#0000FF',
        createdAt: now,
        updatedAt: now,
      );

      final tasks = [
        Task(
          id: 't_direct',
          userId: 'u1',
          labelId: 'l_parent',
          title: 'Review strategy',
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: 't_code',
          userId: 'u1',
          labelId: 'l_child1',
          title: 'Implement feature',
          createdAt: now,
          updatedAt: now,
        ),
        Task(
          id: 't_meet',
          userId: 'u1',
          labelId: 'l_child2',
          title: 'Team standup',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final occurrences = [
        // Direct parent task: 1 occurrence, completed
        TaskOccurrence(
          id: 'occ_dir',
          userId: 'u1',
          taskId: 't_direct',
          occurrenceDate: now,
          status: TaskStatus.done,
          createdAt: now,
          updatedAt: now,
        ),
        // Child 1 (coding): 2 occurrences, 1 completed, 1 pending (50%)
        TaskOccurrence(
          id: 'occ_c1_1',
          userId: 'u1',
          taskId: 't_code',
          occurrenceDate: now,
          status: TaskStatus.done,
          createdAt: now,
          updatedAt: now,
        ),
        TaskOccurrence(
          id: 'occ_c1_2',
          userId: 'u1',
          taskId: 't_code',
          occurrenceDate: now,
          status: TaskStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
        // Child 2 (meetings): 1 occurrence, completed (100%)
        TaskOccurrence(
          id: 'occ_c2_1',
          userId: 'u1',
          taskId: 't_meet',
          occurrenceDate: now,
          status: TaskStatus.done,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final agg = kpiService.aggregateParentLabelKpi(
        parentLabel: parentLabel,
        allLabels: [parentLabel, childLabel1, childLabel2],
        tasks: tasks,
        occurrences: occurrences,
        asOfDate: now,
      );

      // Direct parent: 1 eligible, 1 completed = 100%
      expect(agg.directEligible, 1);
      expect(agg.directCompleted, 1);
      expect(agg.directCompletionRate, 100.0);

      // Children breakdown:
      expect(agg.childBreakdown.length, 2);
      final codingChild = agg.childBreakdown.firstWhere((c) => c.labelId == 'l_child1');
      expect(codingChild.eligibleCount, 2);
      expect(codingChild.completedCount, 1);
      expect(codingChild.completionRate, 50.0);

      final meetChild = agg.childBreakdown.firstWhere((c) => c.labelId == 'l_child2');
      expect(meetChild.eligibleCount, 1);
      expect(meetChild.completedCount, 1);
      expect(meetChild.completionRate, 100.0);

      // Weighted aggregate: 3 completed / 4 eligible = 75%
      expect(agg.totalCompleted, 3);
      expect(agg.totalEligible, 4);
      expect(agg.weightedCompletionRate, 75.0);
    });

    test('Target progress formulas for count, time, and rate', () {
      // Count-based: 8 completed / 10 target = 80%
      final countProgress = kpiService.calculateTargetProgressPercentage(
        type: KpiType.count,
        currentValue: 8.0,
        targetValue: 10.0,
      );
      expect(countProgress, 80.0);

      // Time-based: 90 mins tracked / 120 mins target = 75%
      final timeProgress = kpiService.calculateTargetProgressPercentage(
        type: KpiType.time,
        currentValue: 90.0,
        targetValue: 120.0,
      );
      expect(timeProgress, 75.0);

      // Rate-based: 85% achieved / 90% target = 94.444...%
      final rateProgress = kpiService.calculateTargetProgressPercentage(
        type: KpiType.rate,
        currentValue: 85.0,
        targetValue: 90.0,
      );
      expect((rateProgress - 94.44).abs() < 0.1, isTrue);
    });
  });

  group('StreakService', () {
    const streakService = StreakService();

    test('Current streak counts consecutive completed days up to today', () {
      final today = DateTime(2026, 10, 15);
      final yesterday = DateTime(2026, 10, 14);
      final dayBefore = DateTime(2026, 10, 13);

      final occurrences = [
        TaskOccurrence(
          id: 's1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: dayBefore,
          status: TaskStatus.done,
          createdAt: dayBefore,
          updatedAt: dayBefore,
        ),
        TaskOccurrence(
          id: 's2',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: yesterday,
          status: TaskStatus.done,
          createdAt: yesterday,
          updatedAt: yesterday,
        ),
        TaskOccurrence(
          id: 's3',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.done,
          createdAt: today,
          updatedAt: today,
        ),
      ];

      final result = streakService.calculateStreak(
        occurrences: occurrences,
        asOfDate: today,
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
      expect(result.completedToday, isTrue);
      expect(result.isMaintainedToday, isTrue);
      expect(result.completedDays, 3);
    });

    test('If today has tasks and none completed yet, yesterday streak is preserved', () {
      final today = DateTime(2026, 10, 15);
      final yesterday = DateTime(2026, 10, 14);
      final dayBefore = DateTime(2026, 10, 13);

      final occurrences = [
        TaskOccurrence(
          id: 's1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: dayBefore,
          status: TaskStatus.done,
          createdAt: dayBefore,
          updatedAt: dayBefore,
        ),
        TaskOccurrence(
          id: 's2',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: yesterday,
          status: TaskStatus.done,
          createdAt: yesterday,
          updatedAt: yesterday,
        ),
        TaskOccurrence(
          id: 's3',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.pending, // Pending today!
          createdAt: today,
          updatedAt: today,
        ),
      ];

      final result = streakService.calculateStreak(
        occurrences: occurrences,
        asOfDate: today,
      );

      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
      expect(result.completedToday, isFalse);
      expect(result.isMaintainedToday, isTrue);
    });

    test('Grace day preserves streak over a single missed day', () {
      final today = DateTime(2026, 10, 15);
      final yesterday = DateTime(2026, 10, 14); // Missed!
      final dayBefore = DateTime(2026, 10, 13); // Done
      final twoDaysBefore = DateTime(2026, 10, 12); // Done

      final occurrences = [
        TaskOccurrence(
          id: 's1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: twoDaysBefore,
          status: TaskStatus.done,
          createdAt: twoDaysBefore,
          updatedAt: twoDaysBefore,
        ),
        TaskOccurrence(
          id: 's2',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: dayBefore,
          status: TaskStatus.done,
          createdAt: dayBefore,
          updatedAt: dayBefore,
        ),
        TaskOccurrence(
          id: 's3',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: yesterday,
          status: TaskStatus.pending, // Yesterday missed
          createdAt: yesterday,
          updatedAt: yesterday,
        ),
        TaskOccurrence(
          id: 's4',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.done, // Today done
          createdAt: today,
          updatedAt: today,
        ),
      ];

      // With grace day: yesterday is bridged, streak is 3 (today + 2 days before)
      final withGrace = streakService.calculateStreak(
        occurrences: occurrences,
        asOfDate: today,
        enableGraceDay: true,
        graceDaysAllowed: 1,
      );
      expect(withGrace.currentStreak, 3);
      expect(withGrace.graceDaysUsedInCurrentStreak, 1);

      // Without grace day: yesterday breaks the streak, currentStreak is 1 (today only)
      final withoutGrace = streakService.calculateStreak(
        occurrences: occurrences,
        asOfDate: today,
        enableGraceDay: false,
      );
      expect(withoutGrace.currentStreak, 1);
      expect(withoutGrace.longestStreak, 2); // 2 days before
    });

    test('Future occurrences do not count as missed dates', () {
      final today = DateTime(2026, 10, 15);
      final tomorrow = DateTime(2026, 10, 16);

      final occurrences = [
        TaskOccurrence(
          id: 's1',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: today,
          status: TaskStatus.done,
          createdAt: today,
          updatedAt: today,
        ),
        TaskOccurrence(
          id: 's2',
          userId: 'u1',
          taskId: 't1',
          occurrenceDate: tomorrow,
          status: TaskStatus.pending,
          createdAt: today,
          updatedAt: today,
        ),
      ];

      final result = streakService.calculateStreak(
        occurrences: occurrences,
        asOfDate: today,
      );

      expect(result.currentStreak, 1);
      expect(result.eligibleScheduledDays, 1);
    });
  });

  group('TimerService', () {
    const timerService = TimerService();
    final now = DateTime(2026, 10, 15);

    test('TimerService correctly calculates running duration from timestamp', () {
      final start = DateTime(2026, 10, 15, 10, 0, 0);
      final session = timerService.startTimer(
        userId: 'u1',
        taskId: 't1',
        now: start,
      );

      expect(session.status, TimerSessionStatus.running);
      expect(session.elapsedSeconds, 0);

      // Check after 25 seconds
      final checkTime = start.add(const Duration(seconds: 25));
      final elapsedSec = timerService.calculateElapsedSeconds(session, checkTime);
      expect(elapsedSec, 25);
    });

    test('TimerService pause excludes paused interval from total elapsed time', () {
      final start = DateTime(2026, 10, 15, 10, 0, 0);
      var session = timerService.startTimer(
        userId: 'u1',
        taskId: 't1',
        now: start,
      );

      // Run for 30 seconds, then pause
      final pauseTime = start.add(const Duration(seconds: 30));
      session = timerService.pauseTimer(session, now: pauseTime);

      expect(session.status, TimerSessionStatus.paused);
      expect(session.elapsedSeconds, 30);

      // While paused for 10 minutes, elapsed duration must REMAIN 30 seconds
      final duringPause = pauseTime.add(const Duration(minutes: 10));
      final elapsedSec = timerService.calculateElapsedSeconds(session, duringPause);
      expect(elapsedSec, 30);

      // Resume after 10 minutes
      final resumeTime = duringPause;
      session = timerService.resumeTimer(session, now: resumeTime);

      expect(session.status, TimerSessionStatus.running);
      expect(session.startedAt, resumeTime);
      expect(session.elapsedSeconds, 30);

      // Run for 20 more seconds
      final checkTime = resumeTime.add(const Duration(seconds: 20));
      final finalSec = timerService.calculateElapsedSeconds(session, checkTime);
      expect(finalSec, 50); // 30 + 20

      // Stop timer
      session = timerService.stopTimer(session, now: checkTime);
      expect(session.status, TimerSessionStatus.completed);
      expect(session.elapsedSeconds, 50);
    });

    test('TimerService enforces single active session rule', () {
      final start = DateTime(2026, 10, 15, 10, 0, 0);
      final session1 = timerService.startTimer(
        userId: 'u1',
        taskId: 't1',
        sessionId: 'sess_1',
        now: start,
      );

      expect(
        () => timerService.startTimer(
          userId: 'u1',
          taskId: 't2',
          sessionId: 'sess_2',
          existingSessions: [session1],
          stopActiveFirst: false,
          now: start,
        ),
        throwsA(isA<ActiveTimerException>()),
      );
    });

    test('TimerService aggregate durations across multiple completed sessions', () {
      final s1 = TimerSession(
        id: 's1',
        userId: 'u1',
        taskId: 't1',
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 15)),
        elapsedSeconds: 900,
        status: TimerSessionStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      final s2 = TimerSession(
        id: 's2',
        userId: 'u1',
        taskId: 't1',
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 30)),
        elapsedSeconds: 1800,
        status: TimerSessionStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      final s3 = TimerSession(
        id: 's3',
        userId: 'u1',
        taskId: 't2',
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 45)),
        elapsedSeconds: 2700,
        status: TimerSessionStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      final totalMin = timerService.calculateTotalMinutes([s1, s2, s3]);
      expect(totalMin, 90); // 15 + 30 + 45 = 90 mins

      final byTask = timerService.calculateElapsedByTask([s1, s2, s3]);
      expect(byTask['t1']?.inMinutes, 45); // 15 + 30
      expect(byTask['t2']?.inMinutes, 45); // 45
    });
  });
}
