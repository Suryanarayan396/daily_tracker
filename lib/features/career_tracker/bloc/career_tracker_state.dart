import 'package:equatable/equatable.dart';
import '../models/career_tracker_model.dart';

class CareerTrackerState extends Equatable {
  const CareerTrackerState({
    this.isLoading = false,
    this.applications = const [],
    this.currentSalary = 0.0,
    this.targetSalary = 0.0,
    this.errorMessage,
  });

  final bool isLoading;
  final List<CareerTrackerModel> applications;
  final double currentSalary;
  final double targetSalary;
  final String? errorMessage;

  // Getters for UI KPI cards
  int get totalApps => applications.length;
  int get recruitersContacted => applications.where((a) => a.status == 'Recruiter').length;
  int get interviewsScheduled => applications.where((a) => a.status == 'Interview Scheduled').length;
  int get interviewsDone => applications.where((a) => a.status == 'Interview Done').length;
  int get offersReceived => applications.where((a) => a.status == 'Offer').length;
  int get rejected => applications.where((a) => a.status == 'Rejected').length;

  List<CareerTrackerModel> get offers => applications.where((a) => a.status == 'Offer').toList();

  double get salaryPercent => targetSalary > 0
      ? (currentSalary / targetSalary).clamp(0.0, 1.0)
      : 0.0;

  CareerTrackerState copyWith({
    bool? isLoading,
    List<CareerTrackerModel>? applications,
    double? currentSalary,
    double? targetSalary,
    String? errorMessage,
  }) {
    return CareerTrackerState(
      isLoading: isLoading ?? this.isLoading,
      applications: applications ?? this.applications,
      currentSalary: currentSalary ?? this.currentSalary,
      targetSalary: targetSalary ?? this.targetSalary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, applications, currentSalary, targetSalary, errorMessage];
}
