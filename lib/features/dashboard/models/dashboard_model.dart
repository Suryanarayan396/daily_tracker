import 'package:equatable/equatable.dart';

class DashboardModel extends Equatable {
  final String username;
  final double currentSalary;
  final double targetSalary;
  final int totalApplications;
  final Map<String, dynamic>? upcomingInterview; // { 'company': String, 'role': String, 'interviewDate': String }
  final Map<String, int> statusCounts; // { 'Recruiter': int, 'Interview Scheduled': int, ... }
  final double balance;
  final double emergencyFund;
  final double savings;
  final int youtubeTotalContent;
  final int youtubePublishedContent;
  final Map<String, dynamic>? upcomingContent; // { 'title': String, 'target_date': String, 'status': String }

  const DashboardModel({
    required this.username,
    required this.currentSalary,
    required this.targetSalary,
    required this.totalApplications,
    this.upcomingInterview,
    required this.statusCounts,
    required this.balance,
    required this.emergencyFund,
    required this.savings,
    required this.youtubeTotalContent,
    required this.youtubePublishedContent,
    this.upcomingContent,
  });

  @override
  List<Object?> get props => [
        username,
        currentSalary,
        targetSalary,
        totalApplications,
        upcomingInterview,
        statusCounts,
        balance,
        emergencyFund,
        savings,
        youtubeTotalContent,
        youtubePublishedContent,
        upcomingContent,
      ];
}

class DashboardSettingsModel extends Equatable {
  final int id;
  final String welcomeMessage;
  final String dailyMission;
  final int streakDays;
  final int dailyScore;
  final String highestImpactTask;
  final bool isHitCompleted;
  final String currentLawInsight;
  final double targetSalary;

  const DashboardSettingsModel({
    this.id = 1,
    required this.welcomeMessage,
    required this.dailyMission,
    required this.streakDays,
    required this.dailyScore,
    required this.highestImpactTask,
    required this.isHitCompleted,
    required this.currentLawInsight,
    required this.targetSalary,
  });

  DashboardSettingsModel copyWith({
    int? id,
    String? welcomeMessage,
    String? dailyMission,
    int? streakDays,
    int? dailyScore,
    String? highestImpactTask,
    bool? isHitCompleted,
    String? currentLawInsight,
    double? targetSalary,
  }) {
    return DashboardSettingsModel(
      id: id ?? this.id,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      dailyMission: dailyMission ?? this.dailyMission,
      streakDays: streakDays ?? this.streakDays,
      dailyScore: dailyScore ?? this.dailyScore,
      highestImpactTask: highestImpactTask ?? this.highestImpactTask,
      isHitCompleted: isHitCompleted ?? this.isHitCompleted,
      currentLawInsight: currentLawInsight ?? this.currentLawInsight,
      targetSalary: targetSalary ?? this.targetSalary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'welcomeMessage': welcomeMessage,
      'dailyMission': dailyMission,
      'streakDays': streakDays,
      'dailyScore': dailyScore,
      'highestImpactTask': highestImpactTask,
      'isHitCompleted': isHitCompleted ? 1 : 0,
      'currentLawInsight': currentLawInsight,
      'targetSalary': targetSalary,
    };
  }

  factory DashboardSettingsModel.fromMap(Map<String, dynamic> map) {
    return DashboardSettingsModel(
      id: map['id'] as int? ?? 1,
      welcomeMessage: map['welcomeMessage'] as String? ?? '',
      dailyMission: map['dailyMission'] as String? ?? '',
      streakDays: map['streakDays'] as int? ?? 0,
      dailyScore: map['dailyScore'] as int? ?? 0,
      highestImpactTask: map['highestImpactTask'] as String? ?? '',
      isHitCompleted: (map['isHitCompleted'] as int? ?? 0) == 1,
      currentLawInsight: map['currentLawInsight'] as String? ?? '',
      targetSalary: (map['targetSalary'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        welcomeMessage,
        dailyMission,
        streakDays,
        dailyScore,
        highestImpactTask,
        isHitCompleted,
        currentLawInsight,
        targetSalary,
      ];
}
