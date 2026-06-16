import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc(this._repository) : super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardSalaryUpdated>(_onSalaryUpdated);
    on<DashboardGoalProgressUpdated>(_onGoalProgressUpdated);
    on<DashboardDailyScoreIncremented>(_onDailyScoreIncremented);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoadInProgress());
    try {
      final data = await _repository.getDashboardData();
      emit(DashboardLoadSuccess(data));
    } catch (e) {
      emit(DashboardLoadFailure(e.toString()));
    }
  }

  Future<void> _onSalaryUpdated(
    DashboardSalaryUpdated event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoadSuccess) {
      emit(const DashboardLoadInProgress());
      try {
        await _repository.updateSalary(event.salary);
        final data = await _repository.getDashboardData();
        emit(DashboardLoadSuccess(data));
      } catch (e) {
        emit(DashboardLoadFailure(e.toString()));
      }
    }
  }

  Future<void> _onGoalProgressUpdated(
    DashboardGoalProgressUpdated event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoadSuccess) {
      emit(const DashboardLoadInProgress());
      try {
        await _repository.updateGoalProgress(event.progress);
        final data = await _repository.getDashboardData();
        emit(DashboardLoadSuccess(data));
      } catch (e) {
        emit(DashboardLoadFailure(e.toString()));
      }
    }
  }

  Future<void> _onDailyScoreIncremented(
    DashboardDailyScoreIncremented event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoadSuccess) {
      emit(const DashboardLoadInProgress());
      try {
        await _repository.incrementDailyScore();
        final data = await _repository.getDashboardData();
        emit(DashboardLoadSuccess(data));
      } catch (e) {
        emit(DashboardLoadFailure(e.toString()));
      }
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final data = await _repository.getDashboardData();
      emit(DashboardLoadSuccess(data));
    } catch (e) {
      emit(DashboardLoadFailure(e.toString()));
    }
  }
}
