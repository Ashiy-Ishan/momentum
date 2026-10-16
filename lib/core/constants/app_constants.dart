abstract class AppConstants {
  static const String appName = 'Momentum';
  static const String appVersion = '0.1.0';
  static const String databaseName = 'momentum.db';
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxTitleLength = 200;
  static const int maxDescriptionLength = 2000;
  static const int maxRetryAttempts = 5;
  static const Duration syncDebounce = Duration(seconds: 3);
  static const Duration wallpaperDebounce = Duration(seconds: 10);
  static const String defaultTimezone = 'UTC';
  static const int defaultWeekStartDay = DateTime.monday;

  // Responsive Breakpoints
  static const double desktopBreakpoint = 1024.0;
  static const double tabletBreakpoint = 600.0;

  // Supabase Backend Defaults (Embedded, SQL-injection free, zero manual settings entry)
  static const String defaultSupabaseUrl =
      'https://aexjbjdknoknfqgevktl.supabase.co';
  static const String defaultSupabaseAnonKey =
      'sb_publishable_qOZAl_wFWSMN6fG8XCE-WQ_jmKio-mZ';
}
