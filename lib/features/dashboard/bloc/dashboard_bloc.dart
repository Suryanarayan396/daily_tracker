import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;
  StreamSubscription? _watchSub;

  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardHitUpdated>(_onHitUpdated);
    on<DashboardHitToggled>(_onHitToggled);
    on<DashboardInsightRotated>(_onInsightRotated);
    on<DashboardTargetSalaryUpdated>(_onTargetSalaryUpdated);

    // Automatically refresh Dashboard on any SQLite table change
    _watchSub = _repository.watchChanges().listen((_) {
      add(const DashboardRefreshRequested());
    });
  }

  @override
  Future<void> close() {
    _watchSub?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await _repository.getDashboardData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await _repository.getDashboardData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onHitUpdated(
    DashboardHitUpdated event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.updateHit(event.task);
      final data = await _repository.getDashboardData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onHitToggled(
    DashboardHitToggled event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.toggleHit();
      final data = await _repository.getDashboardData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onInsightRotated(
    DashboardInsightRotated event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.rotateInsight();
      final data = await _repository.getDashboardData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onTargetSalaryUpdated(
    DashboardTargetSalaryUpdated event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.updateTargetSalary(event.target);
      final data = await _repository.getDashboardData();
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
