import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/career_tracker_model.dart';
import 'career_tracker_repository.dart';

class CareerTrackerRepositoryImpl implements CareerTrackerRepository {
  const CareerTrackerRepositoryImpl();

  Database get _db => SqliteService.db;

  @override
  Future<List<CareerTrackerModel>> getAllApplications() async {
    final maps = await _db.query('job_applications', orderBy: 'dateApplied DESC');
    return maps.map((map) => CareerTrackerModel.fromMap(map)).toList();
  }

  Future<CareerTrackerModel?> getById(int id) async {
    final maps = await _db.query(
      'job_applications',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CareerTrackerModel.fromMap(maps.first);
  }

  @override
  Stream<String> watchChanges() {
    return SqliteService.changeStream;
  }

  @override
  Future<void> addApplication({
    required String company,
    required String role,
    required String status,
    required double salary,
    required bool recruiterContacted,
    String interviewDate = '',
    String notes = '',
    String reminderDateTime = '',
  }) async {
    final model = CareerTrackerModel(
      id: 0,
      company: company,
      role: role,
      status: status,
      salary: salary,
      offeredSalary: 0.0,
      dateApplied: DateTime.now(),
      recruiterContacted: recruiterContacted,
      interviewDate: interviewDate,
      notes: notes,
      reminderDateTime: reminderDateTime,
    );

    final insertedId = await _db.insert(
      'job_applications',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Write initial status history entry
    await _db.insert(
      'job_application_status_history',
      {
        'applicationId': insertedId,
        'status': status,
        'changedAt': DateTime.now().toIso8601String(),
      },
    );

    // Schedule notification if status is Interview Scheduled
    if (status == 'Interview Scheduled') {
      String actualReminderTime = reminderDateTime;
      if (actualReminderTime.isEmpty && interviewDate.isNotEmpty) {
        try {
          final DateTime scheduledDate = DateFormat('dd MMM yyyy • hh:mm a').parse(interviewDate);
          final notificationTime = scheduledDate.subtract(const Duration(minutes: 60));
          final finalTime = notificationTime.isBefore(DateTime.now()) ? scheduledDate : notificationTime;
          actualReminderTime = DateFormat('dd MMM yyyy • hh:mm a').format(finalTime);
        } catch (_) {}
      }

      if (actualReminderTime.isNotEmpty) {
        try {
          final DateTime parsedTime = DateFormat('dd MMM yyyy • hh:mm a').parse(actualReminderTime);
          await NotificationService().scheduleNotification(
            id: 10000 + insertedId,
            title: 'Upcoming Interview Reminder',
            body: 'Your interview for $role at $company starts soon!',
            scheduledDate: parsedTime,
          );
        } catch (_) {}
      }
    }

    SqliteService.notify('job_applications');
  }

  @override
  Future<void> updateStatus(int id, String status) async {
    final model = await getById(id);
    if (model == null) return;
    
    final updated = model.copyWith(status: status);

    if (model.status != status) {
      await _db.insert(
        'job_application_status_history',
        {
          'applicationId': id,
          'status': status,
          'changedAt': DateTime.now().toIso8601String(),
        },
      );
    }

    await _db.update(
      'job_applications',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    // Handle notifications
    if (status == 'Interview Scheduled') {
      String actualReminderTime = updated.reminderDateTime;
      if (actualReminderTime.isEmpty && updated.interviewDate.isNotEmpty) {
        try {
          final DateTime scheduledDate = DateFormat('dd MMM yyyy • hh:mm a').parse(updated.interviewDate);
          final notificationTime = scheduledDate.subtract(const Duration(minutes: 60));
          final finalTime = notificationTime.isBefore(DateTime.now()) ? scheduledDate : notificationTime;
          actualReminderTime = DateFormat('dd MMM yyyy • hh:mm a').format(finalTime);
        } catch (_) {}
      }

      if (actualReminderTime.isNotEmpty) {
        try {
          final DateTime parsedTime = DateFormat('dd MMM yyyy • hh:mm a').parse(actualReminderTime);
          await NotificationService().scheduleNotification(
            id: 10000 + id,
            title: 'Upcoming Interview Reminder',
            body: 'Your interview for ${updated.role} at ${updated.company} starts soon!',
            scheduledDate: parsedTime,
          );
        } catch (_) {}
      } else {
        await NotificationService().cancelNotification(10000 + id);
      }
    } else {
      await NotificationService().cancelNotification(10000 + id);
    }

    SqliteService.notify('job_applications');
  }

  @override
  Future<void> updateApplication(CareerTrackerModel model) async {
    final oldModel = await getById(model.id);
    if (oldModel != null && oldModel.status != model.status) {
      await _db.insert(
        'job_application_status_history',
        {
          'applicationId': model.id,
          'status': model.status,
          'changedAt': DateTime.now().toIso8601String(),
        },
      );
    }

    await _db.update(
      'job_applications',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );

    // Handle notifications
    if (model.status == 'Interview Scheduled') {
      String actualReminderTime = model.reminderDateTime;
      if (actualReminderTime.isEmpty && model.interviewDate.isNotEmpty) {
        try {
          final DateTime scheduledDate = DateFormat('dd MMM yyyy • hh:mm a').parse(model.interviewDate);
          final notificationTime = scheduledDate.subtract(const Duration(minutes: 60));
          final finalTime = notificationTime.isBefore(DateTime.now()) ? scheduledDate : notificationTime;
          actualReminderTime = DateFormat('dd MMM yyyy • hh:mm a').format(finalTime);
        } catch (_) {}
      }

      if (actualReminderTime.isNotEmpty) {
        try {
          final DateTime parsedTime = DateFormat('dd MMM yyyy • hh:mm a').parse(actualReminderTime);
          await NotificationService().scheduleNotification(
            id: 10000 + model.id,
            title: 'Upcoming Interview Reminder',
            body: 'Your interview for ${model.role} at ${model.company} starts soon!',
            scheduledDate: parsedTime,
          );
        } catch (_) {}
      } else {
        await NotificationService().cancelNotification(10000 + model.id);
      }
    } else {
      await NotificationService().cancelNotification(10000 + model.id);
    }

    SqliteService.notify('job_applications');
  }

  @override
  Future<void> deleteApplication(int id) async {
    await NotificationService().cancelNotification(10000 + id);
    await _db.delete(
      'job_applications',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _db.delete(
      'job_application_status_history',
      where: 'applicationId = ?',
      whereArgs: [id],
    );
    SqliteService.notify('job_applications');
  }

  @override
  Future<List<CareerStatusHistoryModel>> getStatusHistory(int applicationId) async {
    final maps = await _db.query(
      'job_application_status_history',
      where: 'applicationId = ?',
      whereArgs: [applicationId],
      orderBy: 'changedAt ASC',
    );
    return maps.map((map) => CareerStatusHistoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateSalaryTargets(double currentSalary, double targetSalary) async {
    final financeCount = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM finance_settings WHERE id = 1')) ?? 0;
    if (financeCount == 0) {
      await _db.execute('INSERT OR IGNORE INTO finance_settings (id, salary, netWorth, debt, emergencyFund, emergencyFundTarget, savings, savingsTarget, netWorthHistory, netWorthMonths) VALUES (1, 0, 0, 0, 0, 0, 0, 0, "[]", "[]")');
    }
    
    final dashboardCount = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM dashboard_settings WHERE id = 1')) ?? 0;
    if (dashboardCount == 0) {
      await _db.execute('INSERT OR IGNORE INTO dashboard_settings (id, welcomeMessage, dailyMission, streakDays, dailyScore, highestImpactTask, isHitCompleted, currentLawInsight, targetSalary) VALUES (1, "", "", 0, 0, "", 0, "", 0)');
    }

    await _db.execute('UPDATE finance_settings SET salary = ? WHERE id = 1', [currentSalary]);
    await _db.execute('UPDATE dashboard_settings SET targetSalary = ? WHERE id = 1', [targetSalary]);
    
    SqliteService.notify('finance_settings');
    SqliteService.notify('dashboard_settings');
  }

  @override
  Future<Map<String, double>> getSalaryTargets() async {
    final financeMaps = await _db.query('finance_settings', where: 'id = ?', whereArgs: [1]);
    final dashboardMaps = await _db.query('dashboard_settings', where: 'id = ?', whereArgs: [1]);
    
    final currentSalary = financeMaps.isNotEmpty ? (financeMaps.first['salary'] as num?)?.toDouble() ?? 0.0 : 0.0;
    final targetSalary = dashboardMaps.isNotEmpty ? (dashboardMaps.first['targetSalary'] as num?)?.toDouble() ?? 0.0 : 0.0;
    
    return {
      'currentSalary': currentSalary,
      'targetSalary': targetSalary,
    };
  }
}
