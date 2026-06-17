import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/youtube_tracker_repository.dart';
import 'youtube_tracker_event.dart';
import 'youtube_tracker_state.dart';

class YoutubeTrackerBloc extends Bloc<YoutubeTrackerEvent, YoutubeTrackerState> {
  final YoutubeTrackerRepository _repository;
  StreamSubscription? _statsSub;
  StreamSubscription? _contentSub;

  YoutubeTrackerBloc(this._repository) : super(const YoutubeTrackerState()) {
    on<YoutubeTrackerStarted>(_onStarted);
    on<YoutubeTrackerRefreshRequested>(_onRefreshRequested);
    on<YoutubeTrackerStatUpdated>(_onStatUpdated);
    on<YoutubeTrackerContentAdded>(_onContentAdded);
    on<YoutubeTrackerContentUpdated>(_onContentUpdated);
    on<YoutubeTrackerContentDeleted>(_onContentDeleted);

    _statsSub = _repository.watchChannelStats().listen((_) {
      add(const YoutubeTrackerRefreshRequested());
    });
    _contentSub = _repository.watchContent().listen((_) {
      add(const YoutubeTrackerRefreshRequested());
    });
  }

  Future<void> _onStarted(
    YoutubeTrackerStarted event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final stats = await _repository.getChannelStats();
      final contentList = await _repository.getAllContent();
      emit(state.copyWith(
        isLoading: false,
        stats: stats,
        contentList: contentList,
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
      final stats = await _repository.getChannelStats();
      final contentList = await _repository.getAllContent();
      emit(state.copyWith(
        stats: stats,
        contentList: contentList,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStatUpdated(
    YoutubeTrackerStatUpdated event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.updateChannelStat(event.key, event.value);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onContentAdded(
    YoutubeTrackerContentAdded event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.addContent(
        title: event.title,
        targetDate: event.targetDate,
        reminderDateTime: event.reminderDateTime,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onContentUpdated(
    YoutubeTrackerContentUpdated event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.updateContent(event.content);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onContentDeleted(
    YoutubeTrackerContentDeleted event,
    Emitter<YoutubeTrackerState> emit,
  ) async {
    try {
      await _repository.deleteContent(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _statsSub?.cancel();
    _contentSub?.cancel();
    return super.close();
  }
}
