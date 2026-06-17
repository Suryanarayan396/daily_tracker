import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

final class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

final class DashboardHitUpdated extends DashboardEvent {
  final String task;
  const DashboardHitUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

final class DashboardHitToggled extends DashboardEvent {
  const DashboardHitToggled();
}

final class DashboardInsightRotated extends DashboardEvent {
  const DashboardInsightRotated();
}

final class DashboardTargetSalaryUpdated extends DashboardEvent {
  final double target;
  const DashboardTargetSalaryUpdated(this.target);

  @override
  List<Object?> get props => [target];
}
