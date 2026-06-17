import '../models/youtube_tracker_model.dart';

abstract class YoutubeTrackerRepository {
  Future<YoutubeChannelStatsModel> getChannelStats();
  Stream<String> watchChannelStats();
  Future<void> updateChannelStat(String key, String value);

  Future<List<YoutubeContentModel>> getAllContent();
  Stream<String> watchContent();
  Future<void> addContent({
    required String title,
    required String targetDate,
    String reminderDateTime = '',
  });
  Future<void> updateContent(YoutubeContentModel content);
  Future<void> deleteContent(int id);
}
