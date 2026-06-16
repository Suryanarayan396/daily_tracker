import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

class DashboardSalaryUpdated extends DashboardEvent {
  final double salary;

  const DashboardSalaryUpdated(this.salary);

  @override
  List<Object?> get props => [salary];
}

class DashboardGoalProgressUpdated extends DashboardEvent {
  final double progress;

  const DashboardGoalProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DashboardDailyScoreIncremented extends DashboardEvent {
  const DashboardDailyScoreIncremented();
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}
