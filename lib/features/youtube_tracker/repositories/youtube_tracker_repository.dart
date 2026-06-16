import '../models/youtube_tracker_model.dart';

abstract class YoutubeTrackerRepository {
  Future<YoutubeSettingsModel> getSettings();
  Stream<String> watchSettings();
  Future<void> updateSettings({int? subscribers});

  Future<List<YoutubeVideoModel>> getAllVideos();
  Stream<String> watchVideos();
  Future<void> addVideo({
    required String title,
    required String type,
    required String stage,
    int views = 0,
    int watchTimeMinutes = 0,
  });
  Future<void> updateVideo(YoutubeVideoModel model);
  Future<void> deleteVideo(int id);

  Future<List<ContentCalendarEntryModel>> getCalendarEntries();
  Stream<String> watchCalendar();
  Future<void> addCalendarEntry({
    required String title,
    required String type,
    required DateTime scheduledDate,
  });
  Future<void> toggleCalendarEntry(int id);
  Future<void> deleteCalendarEntry(int id);
}
