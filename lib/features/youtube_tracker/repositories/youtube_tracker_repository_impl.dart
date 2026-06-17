import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../../core/services/sqlite_service.dart';
import '../../../core/services/notification_service.dart';
import '../models/youtube_tracker_model.dart';
import 'youtube_tracker_repository.dart';

class YoutubeTrackerRepositoryImpl implements YoutubeTrackerRepository {
  const YoutubeTrackerRepositoryImpl();

  Database get _db => SqliteService.db;

  @override
  Future<YoutubeChannelStatsModel> getChannelStats() async {
    final maps = await _db.query('channel_stats');
    
    String subscribers = '0';
    String totalViews = '0';
    String totalVideos = '0';
    String watchHours = '0';
    String monthlyRevenue = '0';

    for (final map in maps) {
      final key = map['key'] as String;
      final val = map['value'] as String;
      if (key == 'subscribers') subscribers = val;
      if (key == 'views') totalViews = val;
      if (key == 'videos') totalVideos = val;
      if (key == 'watch_hours') watchHours = val;
      if (key == 'monthly_revenue') monthlyRevenue = val;
    }

    return YoutubeChannelStatsModel(
      subscribers: subscribers,
      totalViews: totalViews,
      totalVideos: totalVideos,
      watchHours: watchHours,
      monthlyRevenue: monthlyRevenue,
    );
  }

  @override
  Stream<String> watchChannelStats() {
    return SqliteService.watchTable('channel_stats');
  }

  @override
  Future<void> updateChannelStat(String key, String value) async {
    await _db.insert(
      'channel_stats',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    SqliteService.notify('channel_stats');
  }

  @override
  Future<List<YoutubeContentModel>> getAllContent() async {
    final maps = await _db.query('content', orderBy: 'target_date ASC');
    return maps.map((map) => YoutubeContentModel.fromMap(map)).toList();
  }

  @override
  Stream<String> watchContent() {
    return SqliteService.watchTable('content');
  }

  @override
  Future<void> addContent({
    required String title,
    required String targetDate,
    String reminderDateTime = '',
  }) async {
    final item = YoutubeContentModel(
      id: 0,
      title: title,
      targetDate: targetDate,
      status: 'planned',
      createdAt: DateTime.now(),
      reminderDateTime: reminderDateTime,
    );

    final insertedId = await _db.insert(
      'content',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Schedule notification
    String actualReminder = reminderDateTime;
    if (actualReminder.isEmpty && targetDate.isNotEmpty) {
      try {
        final DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(targetDate);
        final DateTime scheduledDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 9, 0);
        actualReminder = DateFormat('dd MMM yyyy • hh:mm a').format(scheduledDate);
      } catch (_) {}
    }

    if (actualReminder.isNotEmpty) {
      try {
        final DateTime parsedTime = DateFormat('dd MMM yyyy • hh:mm a').parse(actualReminder);
        await NotificationService().scheduleNotification(
          id: 20000 + insertedId,
          title: 'Upcoming Video Release Reminder',
          body: 'Your scheduled video "$title" needs to be published today!',
          scheduledDate: parsedTime,
        );
      } catch (_) {}
    }

    SqliteService.notify('content');
  }

  @override
  Future<void> updateContent(YoutubeContentModel content) async {
    await _db.update(
      'content',
      content.toMap(),
      where: 'id = ?',
      whereArgs: [content.id],
    );

    // Handle notifications
    if (content.status != 'published') {
      String actualReminder = content.reminderDateTime;
      if (actualReminder.isEmpty && content.targetDate.isNotEmpty) {
        try {
          final DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(content.targetDate);
          final DateTime scheduledDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 9, 0);
          actualReminder = DateFormat('dd MMM yyyy • hh:mm a').format(scheduledDate);
        } catch (_) {}
      }

      if (actualReminder.isNotEmpty) {
        try {
          final DateTime parsedTime = DateFormat('dd MMM yyyy • hh:mm a').parse(actualReminder);
          await NotificationService().scheduleNotification(
            id: 20000 + content.id,
            title: 'Upcoming Video Release Reminder',
            body: 'Your scheduled video "${content.title}" needs to be published today!',
            scheduledDate: parsedTime,
          );
        } catch (_) {}
      } else {
        await NotificationService().cancelNotification(20000 + content.id);
      }
    } else {
      await NotificationService().cancelNotification(20000 + content.id);
    }

    SqliteService.notify('content');
  }

  @override
  Future<void> deleteContent(int id) async {
    await NotificationService().cancelNotification(20000 + id);
    await _db.delete(
      'content',
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('content');
  }
}
