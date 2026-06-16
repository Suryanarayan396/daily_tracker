import 'package:equatable/equatable.dart';
import '../models/dashboard_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoadInProgress extends DashboardState {
  const DashboardLoadInProgress();
}

class DashboardLoadSuccess extends DashboardState {
  final DashboardModel data;

  const DashboardLoadSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class DashboardLoadFailure extends DashboardState {
  final String errorMessage;

  const DashboardLoadFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
