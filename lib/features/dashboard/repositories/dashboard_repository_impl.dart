import 'package:sqflite/sqflite.dart';
import '../../../core/services/sqlite_service.dart';
import '../../finance_tracker/models/finance_tracker_model.dart';
import '../models/dashboard_model.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl();

  Database get _db => SqliteService.db;

  Future<DashboardSettingsModel> _getSettings() async {
    final maps = await _db.query(
      'dashboard_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      final settings = DashboardSettingsModel(
        id: 1,
        welcomeMessage: "Hello, Ambitious Developer!",
        dailyMission: "Optimize the 20% that drives 80% of your career growth.",
        streakDays: 5,
        dailyScore: 85,
        highestImpactTask: "Design LifeOS component architecture",
        isHitCompleted: false,
        currentLawInsight: "Work expands to fill the time available. Set a 2-hour deadline for your next coding session. (Parkinson's Law)",
        targetSalary: 120000.0,
      );

      await _db.insert(
        'dashboard_settings',
        settings.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return settings;
    }

    return DashboardSettingsModel.fromMap(maps.first);
  }

  @override
  Future<DashboardModel> getDashboardData() async {
    final settings = await _getSettings();

    // Query other tables
    // 1. Finance Settings
    final financeMaps = await _db.query(
      'finance_settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    final finance = financeMaps.isNotEmpty ? FinanceSettingsModel.fromMap(financeMaps.first) : null;

    // 2. Career apps count
    final careerCountResult = await _db.rawQuery('SELECT COUNT(*) FROM job_applications');
    final careerAppsCount = Sqflite.firstIntValue(careerCountResult) ?? 0;

    // 3. Youtube videos count where stage = 'Published' and type = 'Long'
    final youtubeCountResult = await _db.rawQuery(
      "SELECT COUNT(*) FROM youtube_videos WHERE stage = ? AND type = ?",
      ['Published', 'Long'],
    );
    final youtubeVideosCount = Sqflite.firstIntValue(youtubeCountResult) ?? 0;

    return DashboardModel(
      welcomeMessage: settings.welcomeMessage,
      dailyMission: settings.dailyMission,
      streakDays: settings.streakDays,
      dailyScore: settings.dailyScore,
      highestImpactTask: settings.highestImpactTask,
      isHitCompleted: settings.isHitCompleted,
      currentLawInsight: settings.currentLawInsight,
      currentSalary: finance?.salary ?? 75000.0,
      targetSalary: settings.targetSalary,
      debt: finance?.debt ?? 45000.0,
      emergencyFund: finance?.emergencyFund ?? 120000.0,
      careerApplicationsCount: careerAppsCount,
      youtubeVideosUploadedCount: youtubeVideosCount,
    );
  }

  @override
  Future<void> updateHit(String task) async {
    final settings = await _getSettings();
    settings.highestImpactTask = task;
    settings.isHitCompleted = false;

    await _db.update(
      'dashboard_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('dashboard_settings');
  }

  @override
  Future<void> toggleHit() async {
    final settings = await _getSettings();
    settings.isHitCompleted = !settings.isHitCompleted;
    settings.dailyScore = settings.isHitCompleted
        ? (settings.dailyScore + 15).clamp(0, 100)
        : (settings.dailyScore - 15).clamp(0, 100);

    await _db.update(
      'dashboard_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('dashboard_settings');
  }

  @override
  Future<void> rotateInsight() async {
    final settings = await _getSettings();
    final insights = [
      "Work expands to fill the time available. Set a 2-hour deadline for your next coding session. (Parkinson's Law)",
      "What could go wrong, will go wrong. Back up your repository and write unit tests for critical paths. (Murphy's Law)",
      "80% of results come from 20% of efforts. Double down on your core feature instead of visual tweaks. (Pareto Principle)",
      "The biggest problem is that no one tells you what to do. Clearly define your tasks for today. (Gilbert's Law)",
      "The simplest solution is usually the correct one. Refactor that complex nested class into smaller widgets. (Occam's Razor)",
      "Never attribute to malice that which is adequately explained by ignorance. Give your team member the benefit of doubt. (Hanlon's Razor)",
      "In a hierarchy, people rise to their level of incompetence. Switch from passive reading to coding to keep growing. (Peter Principle)",
    ];
    final idx = insights.indexOf(settings.currentLawInsight);
    settings.currentLawInsight = insights[(idx + 1) % insights.length];

    await _db.update(
      'dashboard_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('dashboard_settings');
  }
}
