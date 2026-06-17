import 'package:equatable/equatable.dart';
import '../models/youtube_tracker_model.dart';

sealed class YoutubeTrackerEvent extends Equatable {
  const YoutubeTrackerEvent();

  @override
  List<Object?> get props => [];
}

final class YoutubeTrackerStarted extends YoutubeTrackerEvent {
  const YoutubeTrackerStarted();
}

final class YoutubeTrackerRefreshRequested extends YoutubeTrackerEvent {
  const YoutubeTrackerRefreshRequested();
}

final class YoutubeTrackerStatUpdated extends YoutubeTrackerEvent {
  final String key;
  final String value;

  const YoutubeTrackerStatUpdated({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

final class YoutubeTrackerContentAdded extends YoutubeTrackerEvent {
  final String title;
  final String targetDate;
  final String reminderDateTime;

  const YoutubeTrackerContentAdded({
    required this.title,
    required this.targetDate,
    this.reminderDateTime = '',
  });

  @override
  List<Object?> get props => [title, targetDate, reminderDateTime];
}

final class YoutubeTrackerContentUpdated extends YoutubeTrackerEvent {
  final YoutubeContentModel content;

  const YoutubeTrackerContentUpdated({required this.content});

  @override
  List<Object?> get props => [content];
}

final class YoutubeTrackerContentDeleted extends YoutubeTrackerEvent {
  final int id;

  const YoutubeTrackerContentDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}
