import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/career_tracker_model.dart';
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
      final targets = await _repository.getSalaryTargets();
      emit(state.copyWith(
        isLoading: false,
        applications: apps,
        currentSalary: targets['currentSalary'] ?? 0.0,
        targetSalary: targets['targetSalary'] ?? 0.0,
      ));
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
      final targets = await _repository.getSalaryTargets();
      emit(state.copyWith(
        applications: apps,
        currentSalary: targets['currentSalary'] ?? 0.0,
        targetSalary: targets['targetSalary'] ?? 0.0,
      ));
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
        reminderDateTime: event.reminderDateTime,
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
    try {
      await _repository.updateSalaryTargets(event.currentSalary, event.targetSalary);
      emit(state.copyWith(
        currentSalary: event.currentSalary,
        targetSalary: event.targetSalary,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<List<CareerStatusHistoryModel>> getStatusHistory(int applicationId) {
    return _repository.getStatusHistory(applicationId);
  }

  @override
  Future<void> close() {
    _watchSub?.cancel();
    return super.close();
  }
}
