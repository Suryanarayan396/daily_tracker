import 'package:equatable/equatable.dart';
import '../models/youtube_tracker_model.dart';

class YoutubeTrackerState extends Equatable {
  const YoutubeTrackerState({
    this.isLoading = false,
    this.stats = const YoutubeChannelStatsModel(),
    this.contentList = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final YoutubeChannelStatsModel stats;
  final List<YoutubeContentModel> contentList;
  final String? errorMessage;

  List<YoutubeContentModel> get plannedContent =>
      contentList.where((c) => c.status == 'planned').toList();

  List<YoutubeContentModel> get pipelineContent => contentList
      .where((c) => ['scripting', 'filming', 'editing', 'thumbnail'].contains(c.status))
      .toList();

  List<YoutubeContentModel> get publishedContent =>
      contentList.where((c) => c.status == 'published').toList();

  YoutubeTrackerState copyWith({
    bool? isLoading,
    YoutubeChannelStatsModel? stats,
    List<YoutubeContentModel>? contentList,
    String? errorMessage,
  }) {
    return YoutubeTrackerState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      contentList: contentList ?? this.contentList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, stats, contentList, errorMessage];
}
