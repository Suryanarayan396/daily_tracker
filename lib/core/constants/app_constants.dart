class AppConstants {
  AppConstants._();

  static const String appName = 'Daily Tracker';
  
  // Storage Keys
  static const String keyUserTheme = 'user_theme_mode';
  static const String keyDailyReflection = 'daily_reflections';
  static const String keyLearningTracker = 'learning_sessions';
  static const String keyFinanceTracker = 'finance_records';
  static const String keyCareerTracker = 'career_goals';
  static const String keyYoutubeTracker = 'youtube_stats';
  
  // Date Formats
  static const String dateFormatFull = 'yyyy-MM-dd';
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 350);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
}
