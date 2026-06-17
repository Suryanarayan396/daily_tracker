import 'package:equatable/equatable.dart';
import '../models/career_tracker_model.dart';

sealed class CareerTrackerEvent extends Equatable {
  const CareerTrackerEvent();

  @override
  List<Object?> get props => [];
}

final class CareerTrackerStarted extends CareerTrackerEvent {
  const CareerTrackerStarted();
}

final class CareerTrackerRefreshRequested extends CareerTrackerEvent {
  const CareerTrackerRefreshRequested();
}

final class CareerTrackerApplicationAdded extends CareerTrackerEvent {
  final String company;
  final String role;
  final String status;
  final double salary;
  final bool recruiterContacted;
  final String interviewDate;
  final String notes;
  final String reminderDateTime;

  const CareerTrackerApplicationAdded({
    required this.company,
    required this.role,
    required this.status,
    required this.salary,
    required this.recruiterContacted,
    this.interviewDate = '',
    this.notes = '',
    this.reminderDateTime = '',
  });

  @override
  List<Object?> get props => [company, role, status, salary, recruiterContacted, interviewDate, notes, reminderDateTime];
}

final class CareerTrackerStatusUpdated extends CareerTrackerEvent {
  final int id;
  final String status;

  const CareerTrackerStatusUpdated({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

final class CareerTrackerApplicationUpdated extends CareerTrackerEvent {
  final CareerTrackerModel model;

  const CareerTrackerApplicationUpdated({required this.model});

  @override
  List<Object?> get props => [model];
}

final class CareerTrackerApplicationDeleted extends CareerTrackerEvent {
  final int id;

  const CareerTrackerApplicationDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

final class CareerTrackerSalaryTargetsUpdated extends CareerTrackerEvent {
  final double currentSalary;
  final double targetSalary;

  const CareerTrackerSalaryTargetsUpdated({required this.currentSalary, required this.targetSalary});

  @override
  List<Object?> get props => [currentSalary, targetSalary];
}
