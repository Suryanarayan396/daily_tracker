import 'package:sqflite/sqflite.dart';
import '../../../core/services/sqlite_service.dart';
import '../models/youtube_tracker_model.dart';
import 'youtube_tracker_repository.dart';

class YoutubeTrackerRepositoryImpl implements YoutubeTrackerRepository {
  const YoutubeTrackerRepositoryImpl();

  Database get _db => SqliteService.db;

  @override
  Future<YoutubeSettingsModel> getSettings() async {
    final maps = await _db.query(
      'youtube_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      final settings = const YoutubeSettingsModel(id: 1, subscribers: 1240);
      await _db.insert(
        'youtube_settings',
        settings.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return settings;
    }
    return YoutubeSettingsModel.fromMap(maps.first);
  }

  @override
  Stream<String> watchSettings() {
    return SqliteService.watchTable('youtube_settings');
  }

  @override
  Future<void> updateSettings({int? subscribers}) async {
    final settings = await getSettings();
    final updated = settings.copyWith(subscribers: subscribers);
    await _db.update(
      'youtube_settings',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('youtube_settings');
  }

  @override
  Future<List<YoutubeVideoModel>> getAllVideos() async {
    final maps = await _db.query('youtube_videos', orderBy: 'createdAt DESC');
    if (maps.isEmpty) {
      final defaults = [
        YoutubeVideoModel(
          id: 0,
          title: 'Riverpod vs BLoC in 2025',
          type: 'Long',
          stage: 'Published',
          views: 8200,
          watchTimeMinutes: 32400,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        YoutubeVideoModel(
          id: 0,
          title: 'Flutter Clean Architecture',
          type: 'Long',
          stage: 'Published',
          views: 4200,
          watchTimeMinutes: 16200,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        YoutubeVideoModel(
          id: 0,
          title: 'BLoC in 60 Seconds',
          type: 'Short',
          stage: 'Published',
          views: 2100,
          watchTimeMinutes: 1050,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        YoutubeVideoModel(
          id: 0,
          title: 'GoRouter Explained',
          type: 'Short',
          stage: 'Published',
          views: 900,
          watchTimeMinutes: 450,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        YoutubeVideoModel(
          id: 0,
          title: 'Flutter State Mgmt Deep Dive',
          type: 'Long',
          stage: 'Editing',
          views: 0,
          watchTimeMinutes: 0,
          createdAt: DateTime.now(),
        ),
        YoutubeVideoModel(
          id: 0,
          title: 'Building LifeOS from Scratch',
          type: 'Long',
          stage: 'Recording',
          views: 0,
          watchTimeMinutes: 0,
          createdAt: DateTime.now(),
        ),
        YoutubeVideoModel(
          id: 0,
          title: 'Dart Isolates in 60s',
          type: 'Short',
          stage: 'Script',
          views: 0,
          watchTimeMinutes: 0,
          createdAt: DateTime.now(),
        ),
      ];

      for (final item in defaults) {
        await _db.insert(
          'youtube_videos',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      SqliteService.notify('youtube_videos');
      return getAllVideos();
    }
    return maps.map((map) => YoutubeVideoModel.fromMap(map)).toList();
  }

  Future<YoutubeVideoModel?> getVideoById(int id) async {
    final maps = await _db.query(
      'youtube_videos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return YoutubeVideoModel.fromMap(maps.first);
  }

  @override
  Stream<String> watchVideos() {
    return SqliteService.watchTable('youtube_videos');
  }

  @override
  Future<void> addVideo({
    required String title,
    required String type,
    required String stage,
    int views = 0,
    int watchTimeMinutes = 0,
  }) async {
    final model = YoutubeVideoModel(
      id: 0,
      title: title,
      type: type,
      stage: stage,
      views: views,
      watchTimeMinutes: watchTimeMinutes,
      createdAt: DateTime.now(),
    );

    await _db.insert(
      'youtube_videos',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    SqliteService.notify('youtube_videos');
  }

  @override
  Future<void> updateVideo(YoutubeVideoModel model) async {
    await _db.update(
      'youtube_videos',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
    SqliteService.notify('youtube_videos');
  }

  @override
  Future<void> deleteVideo(int id) async {
    await _db.delete(
      'youtube_videos',
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('youtube_videos');
  }

  @override
  Future<List<ContentCalendarEntryModel>> getCalendarEntries() async {
    final maps = await _db.query('content_calendar', orderBy: 'scheduledDate ASC');
    if (maps.isEmpty) {
      final defaults = [
        ContentCalendarEntryModel(
          id: 0,
          title: 'Flutter State Mgmt Deep Dive',
          type: 'Long',
          scheduledDate: DateTime.now().add(const Duration(days: 3)),
          isPublished: false,
        ),
        ContentCalendarEntryModel(
          id: 0,
          title: 'Dart Isolates in 60s',
          type: 'Short',
          scheduledDate: DateTime.now().add(const Duration(days: 5)),
          isPublished: false,
        ),
        ContentCalendarEntryModel(
          id: 0,
          title: 'Building LifeOS from Scratch',
          type: 'Long',
          scheduledDate: DateTime.now().add(const Duration(days: 10)),
          isPublished: false,
        ),
        ContentCalendarEntryModel(
          id: 0,
          title: 'CustomPainter Tips',
          type: 'Short',
          scheduledDate: DateTime.now().add(const Duration(days: 12)),
          isPublished: false,
        ),
        ContentCalendarEntryModel(
          id: 0,
          title: 'Async in Dart Explained',
          type: 'Long',
          scheduledDate: DateTime.now().add(const Duration(days: 17)),
          isPublished: false,
        ),
      ];

      for (final item in defaults) {
        await _db.insert(
          'content_calendar',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      SqliteService.notify('content_calendar');
      return getCalendarEntries();
    }
    return maps.map((map) => ContentCalendarEntryModel.fromMap(map)).toList();
  }

  Future<ContentCalendarEntryModel?> getCalendarEntryById(int id) async {
    final maps = await _db.query(
      'content_calendar',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ContentCalendarEntryModel.fromMap(maps.first);
  }

  @override
  Stream<String> watchCalendar() {
    return SqliteService.watchTable('content_calendar');
  }

  @override
  Future<void> addCalendarEntry({
    required String title,
    required String type,
    required DateTime scheduledDate,
  }) async {
    final model = ContentCalendarEntryModel(
      id: 0,
      title: title,
      type: type,
      scheduledDate: scheduledDate,
      isPublished: false,
    );

    await _db.insert(
      'content_calendar',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    SqliteService.notify('content_calendar');
  }

  @override
  Future<void> toggleCalendarEntry(int id) async {
    final model = await getCalendarEntryById(id);
    if (model == null) return;
    
    final updated = model.copyWith(isPublished: !model.isPublished);

    await _db.update(
      'content_calendar',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('content_calendar');
  }

  @override
  Future<void> deleteCalendarEntry(int id) async {
    await _db.delete(
      'content_calendar',
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('content_calendar');
  }
}
