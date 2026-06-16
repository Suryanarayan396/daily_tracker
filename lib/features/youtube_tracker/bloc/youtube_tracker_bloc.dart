import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/youtube_tracker_repository.dart';
import 'youtube_tracker_event.dart';
import 'youtube_tracker_state.dart';

class YoutubeTrackerBloc extends Bloc<YoutubeTrackerEvent, YoutubeTrackerState> {
  final YoutubeTrackerRepository _repository;
  StreamSubscription? _settingsSub;
  StreamSubscription? _videosSub;
  StreamSubscription? _calendarSub;

  YoutubeTrackerBloc(this._repository) : super(const YoutubeTrackerState()) {
    on<YoutubeTrackerStarted>(_onStarted);
    on<YoutubeTrackerRefreshRequested>(_onRefreshRequested);
    on<YoutubeTrackerSubscribersUpdated>(_onSubscribersUpdated);
    on<YoutubeTrackerVideoAdded>(_onVideoAdded);
    on<YoutubeTrackerVideoUpdated>(_onVideoUpdated);
    on<YoutubeTrackerVideoDeleted>(_onVideoDeleted);
    on<YoutubeTrackerCalendarEntryAdded>(_onCalendarEntryAdded);
    on<YoutubeTrackerCalendarEntryToggled>(_onCalendarEntryToggled);
    on<YoutubeTrackerCalendarEntryDeleted>(_onCalendarEntryDeleted);

    _settingsSub = _repository.watchSettings().listen((_) {
      add(const YoutubeTrackerRefreshRequested());
    });
    _videosSub = _repository.watchVideos().listen((_) {
      add(const YoutubeTrackerRefreshRequested());
    });
    _calendarSub = _repository.watchCalendar().listen((_) {
      add(const YoutubeTrackerRefreshRequested());
    });
  }

  Future<void> _onStarted(
    YoutubeTrackerStarted event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final settings = await _repository.getSettings();
      final videos = await _repository.getAllVideos();
      final calendar = await _repository.getCalendarEntries();
      emit(state.copyWith(
        isLoading: false,
        settings: settings,
        videos: videos,
        calendarEntries: calendar,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    YoutubeTrackerRefreshRequested event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      final settings = await _repository.getSettings();
      final videos = await _repository.getAllVideos();
      final calendar = await _repository.getCalendarEntries();
      emit(state.copyWith(
        settings: settings,
        videos: videos,
        calendarEntries: calendar,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSubscribersUpdated(
    YoutubeTrackerSubscribersUpdated event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.updateSettings(subscribers: event.subscribers);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onVideoAdded(
    YoutubeTrackerVideoAdded event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.addVideo(
        title: event.title,
        type: event.type,
        stage: event.stage,
        views: event.views,
        watchTimeMinutes: event.watchTimeMinutes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onVideoUpdated(
    YoutubeTrackerVideoUpdated event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.updateVideo(event.model);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onVideoDeleted(
    YoutubeTrackerVideoDeleted event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.deleteVideo(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCalendarEntryAdded(
    YoutubeTrackerCalendarEntryAdded event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.addCalendarEntry(
        title: event.title,
        type: event.type,
        scheduledDate: event.scheduledDate,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCalendarEntryToggled(
    YoutubeTrackerCalendarEntryToggled event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.toggleCalendarEntry(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCalendarEntryDeleted(
    YoutubeTrackerCalendarEntryDeleted event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.deleteCalendarEntry(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _settingsSub?.cancel();
    _videosSub?.cancel();
    _calendarSub?.cancel();
    return super.close();
  }
}
