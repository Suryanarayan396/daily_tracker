import 'package:equatable/equatable.dart';
import '../models/youtube_tracker_model.dart';

class YoutubeTrackerState extends Equatable {
  const YoutubeTrackerState({
    this.isLoading = false,
    this.settings,
    this.videos = const [],
    this.calendarEntries = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final YoutubeSettingsModel? settings;
  final List<YoutubeVideoModel> videos;
  final List<ContentCalendarEntryModel> calendarEntries;
  final String? errorMessage;

  int get subscribers => settings?.subscribers ?? 0;
  int get totalVideosUploaded => videos.where((v) => v.stage == 'Published').length;
  int get scriptsWritten => videos.where((v) => v.stage == 'Script').length;
  int get shortsUploaded => videos.where((v) => v.type == 'Short' && v.stage == 'Published').length;
  int get longsUploaded => videos.where((v) => v.type == 'Long' && v.stage == 'Published').length;
  int get totalViews => videos.fold(0, (sum, v) => sum + v.views);
  int get watchTimeMinutes => videos.fold(0, (sum, v) => sum + v.watchTimeMinutes);

  int get inPipeline => videos.where((v) => v.stage != 'Published').length;
  List<YoutubeVideoModel> get publishedVideos => videos.where((v) => v.stage == 'Published').toList();
  List<YoutubeVideoModel> get pipelineVideos => videos.where((v) => v.stage != 'Published').toList();

  YoutubeTrackerState copyWith({
    bool? isLoading,
    YoutubeSettingsModel? settings,
    List<YoutubeVideoModel>? videos,
    List<ContentCalendarEntryModel>? calendarEntries,
    String? errorMessage,
  }) {
    return YoutubeTrackerState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      videos: videos ?? this.videos,
      calendarEntries: calendarEntries ?? this.calendarEntries,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, settings, videos, calendarEntries, errorMessage];
}
