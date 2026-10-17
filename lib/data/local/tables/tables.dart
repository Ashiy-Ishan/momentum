import 'package:drift/drift.dart';

class Labels extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get iconName => text().withDefault(const Constant('label'))();
  TextColumn get color => text().withDefault(const Constant('#6366F1'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get labelId => text().nullable()();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().nullable()();
  TextColumn get iconName => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  BoolColumn get hasTimeTracking =>
      boolean().withDefault(const Constant(false))();
  IntColumn get estimatedMinutes => integer().nullable()();
  TextColumn get recurrenceRuleId => text().nullable()();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurrenceRules extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get daysOfWeek => text().nullable()();
  IntColumn get intervalDays => integer().nullable()();
  IntColumn get intervalMonths => integer().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get maxOccurrences => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get taskId => text()();
  DateTimeColumn get occurrenceDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CompletionEvents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get taskId => text()();
  TextColumn get occurrenceId => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TimerSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get taskId => text()();
  TextColumn get occurrenceId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get elapsedSeconds => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('running'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class KpiDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get labelId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get kpiType => text()();
  RealColumn get targetValue => real()();
  RealColumn get currentValue => real().withDefault(const Constant(0.0))();
  RealColumn get longTermTarget => real().nullable()();
  TextColumn get unit => text().withDefault(const Constant('count'))();
  TextColumn get platform => text().withDefault(const Constant('general'))();
  TextColumn get metricCategory =>
      text().withDefault(const Constant('output'))();
  TextColumn get period => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get taskId => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueItems extends Table {
  TextColumn get id => text()();
  TextColumn get syncTableName => text().named('table_name')();
  TextColumn get recordId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class NotificationSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  BoolColumn get hourlyRemindersEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get activeHoursStart =>
      text().withDefault(const Constant('08:00'))();
  TextColumn get activeHoursEnd =>
      text().withDefault(const Constant('22:00'))();
  TextColumn get activeDays =>
      text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  BoolColumn get quietHoursEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get quietStart => text().withDefault(const Constant('22:00'))();
  TextColumn get quietEnd => text().withDefault(const Constant('07:00'))();
  BoolColumn get dailyReportEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dailyReportTime =>
      text().withDefault(const Constant('21:00'))();
  BoolColumn get motivationEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  TextColumn get settingsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
