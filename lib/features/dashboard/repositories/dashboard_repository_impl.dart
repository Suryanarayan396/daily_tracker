import 'package:intl/intl.dart';
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
        welcomeMessage: 'Good morning, Champ! Time to level up.',
        dailyMission: 'Complete your Pareto H.I.T. today to keep up your momentum.',
        streakDays: 0,
        dailyScore: 0,
        highestImpactTask: '',
        isHitCompleted: false,
        currentLawInsight: "Work expands to fill the time available. Set a 2-hour deadline for your next coding session. (Parkinson's Law)",
        targetSalary: 0.0,
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

    // Query Finance Settings
    final financeMaps = await _db.query(
      'finance_settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    final finance = financeMaps.isNotEmpty ? FinanceSettingsModel.fromMap(financeMaps.first) : null;

    // 1. Career Tracker Data
    final totalAppsResult = await _db.rawQuery('SELECT COUNT(*) FROM job_applications');
    final totalApplications = Sqflite.firstIntValue(totalAppsResult) ?? 0;

    final interviewList = await _db.query(
      'job_applications',
      where: "status = 'Interview Scheduled' AND interviewDate != ''",
    );
    Map<String, dynamic>? upcomingInterview;
    if (interviewList.isNotEmpty) {
      final mutableList = List<Map<String, dynamic>>.from(interviewList);
      mutableList.sort((a, b) {
        try {
          final dateA = DateFormat('dd MMM yyyy • hh:mm a').parse(a['interviewDate'] as String);
          final dateB = DateFormat('dd MMM yyyy • hh:mm a').parse(b['interviewDate'] as String);
          return dateA.compareTo(dateB);
        } catch (_) {
          return (a['interviewDate'] as String).compareTo(b['interviewDate'] as String);
        }
      });
      upcomingInterview = {
        'company': mutableList.first['company'],
        'role': mutableList.first['role'],
        'interviewDate': mutableList.first['interviewDate'],
      };
    }

    final statusList = await _db.rawQuery(
      'SELECT status, COUNT(*) as cnt FROM job_applications GROUP BY status'
    );
    final statusCounts = {
      'Recruiter': 0,
      'Interview Scheduled': 0,
      'Interview Done': 0,
      'Offer': 0,
      'Rejected': 0,
    };
    for (final r in statusList) {
      final statusStr = r['status'] as String?;
      final countVal = r['cnt'] as int? ?? 0;
      if (statusStr != null && statusCounts.containsKey(statusStr)) {
        statusCounts[statusStr] = countVal;
      }
    }

    // 2. Finance Tracker Data (Balance calculation)
    final now = DateTime.now();
    final currentMonthStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
    final expensesSumResult = await _db.rawQuery(
      "SELECT SUM(amount) FROM expense_items WHERE SUBSTR(date, 1, 7) = ?",
      [currentMonthStr],
    );
    final monthlyExpenses = (expensesSumResult.first.values.first as num?)?.toDouble() ?? 0.0;
    final balance = (finance?.salary ?? 0.0) - monthlyExpenses;

    // 3. YouTube Tracker Data
    final youtubeTotalResult = await _db.rawQuery('SELECT COUNT(*) FROM content');
    final youtubeTotalContent = Sqflite.firstIntValue(youtubeTotalResult) ?? 0;

    final youtubePublishedResult = await _db.rawQuery(
      "SELECT COUNT(*) FROM content WHERE status = ?",
      ['published'],
    );
    final youtubePublishedContent = Sqflite.firstIntValue(youtubePublishedResult) ?? 0;

    final upcomingContentList = await _db.query(
      'content',
      where: "status != 'published'",
      orderBy: 'target_date ASC',
      limit: 1,
    );
    Map<String, dynamic>? upcomingContent;
    if (upcomingContentList.isNotEmpty) {
      upcomingContent = {
        'title': upcomingContentList.first['title'],
        'target_date': upcomingContentList.first['target_date'],
        'status': upcomingContentList.first['status'],
      };
    }

    return DashboardModel(
      username: "Surya Narayanan",
      currentSalary: finance?.salary ?? 0.0,
      targetSalary: settings.targetSalary,
      totalApplications: totalApplications,
      upcomingInterview: upcomingInterview,
      statusCounts: statusCounts,
      balance: balance,
      emergencyFund: finance?.emergencyFund ?? 0.0,
      savings: finance?.savings ?? 0.0,
      youtubeTotalContent: youtubeTotalContent,
      youtubePublishedContent: youtubePublishedContent,
      upcomingContent: upcomingContent,
    );
  }

  @override
  Future<void> updateHit(String task) async {
    final settings = await _getSettings();
    final updated = settings.copyWith(
      highestImpactTask: task,
      isHitCompleted: false,
    );

    await _db.update(
      'dashboard_settings',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('dashboard_settings');
  }

  @override
  Future<void> toggleHit() async {
    final settings = await _getSettings();
    final newIsHitCompleted = !settings.isHitCompleted;
    final updated = settings.copyWith(
      isHitCompleted: newIsHitCompleted,
    );

    await _db.update(
      'dashboard_settings',
      updated.toMap(),
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
    final updatedInsight = insights[(idx + 1) % insights.length];
    final updated = settings.copyWith(currentLawInsight: updatedInsight);

    await _db.update(
      'dashboard_settings',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('dashboard_settings');
  }

  @override
  Future<void> updateTargetSalary(double target) async {
    final settings = await _getSettings();
    final updated = settings.copyWith(targetSalary: target);
    await _db.update(
      'dashboard_settings',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('dashboard_settings');
  }

  @override
  Stream<String> watchChanges() {
    return SqliteService.changeStream;
  }
}
