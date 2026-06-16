import 'package:equatable/equatable.dart';
import '../models/dashboard_model.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
  });

  final bool isLoading;
  final DashboardModel? data;
  final String? errorMessage;

  DashboardState copyWith({
    bool? isLoading,
    DashboardModel? data,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, data, errorMessage];
}
