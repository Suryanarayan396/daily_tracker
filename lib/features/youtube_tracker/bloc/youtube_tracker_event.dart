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

final class YoutubeTrackerSubscribersUpdated extends YoutubeTrackerEvent {
  final int subscribers;

  const YoutubeTrackerSubscribersUpdated({required this.subscribers});

  @override
  List<Object?> get props => [subscribers];
}

final class YoutubeTrackerVideoAdded extends YoutubeTrackerEvent {
  final String title;
  final String type;
  final String stage;
  final int views;
  final int watchTimeMinutes;

  const YoutubeTrackerVideoAdded({
    required this.title,
    required this.type,
    required this.stage,
    required this.views,
    required this.watchTimeMinutes,
  });

  @override
  List<Object?> get props => [title, type, stage, views, watchTimeMinutes];
}

final class YoutubeTrackerVideoUpdated extends YoutubeTrackerEvent {
  final YoutubeVideoModel model;

  const YoutubeTrackerVideoUpdated({required this.model});

  @override
  List<Object?> get props => [model];
}

final class YoutubeTrackerVideoDeleted extends YoutubeTrackerEvent {
  final int id;

  const YoutubeTrackerVideoDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

final class YoutubeTrackerCalendarEntryAdded extends YoutubeTrackerEvent {
  final String title;
  final String type;
  final DateTime scheduledDate;

  const YoutubeTrackerCalendarEntryAdded({
    required this.title,
    required this.type,
    required this.scheduledDate,
  });

  @override
  List<Object?> get props => [title, type, scheduledDate];
}

final class YoutubeTrackerCalendarEntryToggled extends YoutubeTrackerEvent {
  final int id;

  const YoutubeTrackerCalendarEntryToggled({required this.id});

  @override
  List<Object?> get props => [id];
}

final class YoutubeTrackerCalendarEntryDeleted extends YoutubeTrackerEvent {
  final int id;

  const YoutubeTrackerCalendarEntryDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}
