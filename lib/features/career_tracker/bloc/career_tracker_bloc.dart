import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/career_tracker_repository.dart';
import 'career_tracker_event.dart';
import 'career_tracker_state.dart';

class CareerTrackerBloc extends Bloc<CareerTrackerEvent, CareerTrackerState> {
  final CareerTrackerRepository _repository;
  StreamSubscription? _watchSub;

  CareerTrackerBloc(this._repository) : super(const CareerTrackerState()) {
    on<CareerTrackerStarted>(_onStarted);
    on<CareerTrackerRefreshRequested>(_onRefreshRequested);
    on<CareerTrackerApplicationAdded>(_onApplicationAdded);
    on<CareerTrackerStatusUpdated>(_onStatusUpdated);
    on<CareerTrackerApplicationUpdated>(_onApplicationUpdated);
    on<CareerTrackerApplicationDeleted>(_onApplicationDeleted);
    on<CareerTrackerSalaryTargetsUpdated>(_onSalaryTargetsUpdated);

    // Watch SQLite change notification stream
    _watchSub = _repository.watchChanges().listen((_) {
      add(const CareerTrackerRefreshRequested());
    });
  }

  Future<void> _onStarted(
    CareerTrackerStarted event,
    Emitter<CareerTrackerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final apps = await _repository.getAllApplications();
      emit(state.copyWith(isLoading: false, applications: apps));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    CareerTrackerRefreshRequested event,
    Emitter<CareerTrackerState> emit,
  ) async {
    try {
      final apps = await _repository.getAllApplications();
      emit(state.copyWith(applications: apps));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onApplicationAdded(
    CareerTrackerApplicationAdded event,
    Emitter<CareerTrackerState> emit,
  ) async {
    try {
      await _repository.addApplication(
        company: event.company,
        role: event.role,
        status: event.status,
        salary: event.salary,
        recruiterContacted: event.recruiterContacted,
        interviewDate: event.interviewDate,
        notes: event.notes,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onStatusUpdated(
    CareerTrackerStatusUpdated event,
    Emitter<CareerTrackerState> emit,
  ) async {
    try {
      await _repository.updateStatus(event.id, event.status);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onApplicationUpdated(
    CareerTrackerApplicationUpdated event,
    Emitter<CareerTrackerState> emit,
  ) async {
    try {
      await _repository.updateApplication(event.model);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onApplicationDeleted(
    CareerTrackerApplicationDeleted event,
    Emitter<CareerTrackerState> emit,
  ) async {
    try {
      await _repository.deleteApplication(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSalaryTargetsUpdated(
    CareerTrackerSalaryTargetsUpdated event,
    Emitter<CareerTrackerState> emit,
  ) async {
    emit(state.copyWith(
      currentSalary: event.currentSalary,
      targetSalary: event.targetSalary,
    ));
  }

  @override
  Future<void> close() {
    _watchSub?.cancel();
    return super.close();
  }
}
