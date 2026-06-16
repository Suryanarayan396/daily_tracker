import 'package:equatable/equatable.dart';

class DashboardModel extends Equatable {
  final String welcomeMessage;
  final String dailyMission;
  final int streakDays;
  final int dailyScore;
  final String highestImpactTask;
  final bool isHitCompleted;
  final String currentLawInsight;
  final double currentSalary;
  final double targetSalary;
  final double debt;
  final double emergencyFund;
  final int careerApplicationsCount;
  final int youtubeVideosUploadedCount;

  const DashboardModel({
    required this.welcomeMessage,
    required this.dailyMission,
    required this.streakDays,
    required this.dailyScore,
    required this.highestImpactTask,
    required this.isHitCompleted,
    required this.currentLawInsight,
    required this.currentSalary,
    required this.targetSalary,
    required this.debt,
    required this.emergencyFund,
    required this.careerApplicationsCount,
    required this.youtubeVideosUploadedCount,
  });

  DashboardModel copyWith({
    String? welcomeMessage,
    String? dailyMission,
    int? streakDays,
    int? dailyScore,
    String? highestImpactTask,
    bool? isHitCompleted,
    String? currentLawInsight,
    double? currentSalary,
    double? targetSalary,
    double? debt,
    double? emergencyFund,
    int? careerApplicationsCount,
    int? youtubeVideosUploadedCount,
  }) {
    return DashboardModel(
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      dailyMission: dailyMission ?? this.dailyMission,
      streakDays: streakDays ?? this.streakDays,
      dailyScore: dailyScore ?? this.dailyScore,
      highestImpactTask: highestImpactTask ?? this.highestImpactTask,
      isHitCompleted: isHitCompleted ?? this.isHitCompleted,
      currentLawInsight: currentLawInsight ?? this.currentLawInsight,
      currentSalary: currentSalary ?? this.currentSalary,
      targetSalary: targetSalary ?? this.targetSalary,
      debt: debt ?? this.debt,
      emergencyFund: emergencyFund ?? this.emergencyFund,
      careerApplicationsCount: careerApplicationsCount ?? this.careerApplicationsCount,
      youtubeVideosUploadedCount: youtubeVideosUploadedCount ?? this.youtubeVideosUploadedCount,
    );
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      welcomeMessage: json['welcome_message'] as String? ?? '',
      dailyMission: json['daily_mission'] as String? ?? '',
      streakDays: json['streak_days'] as int? ?? 0,
      dailyScore: json['daily_score'] as int? ?? 0,
      highestImpactTask: json['highest_impact_task'] as String? ?? '',
      isHitCompleted: (json['is_hit_completed'] as bool? ?? false),
      currentLawInsight: json['current_law_insight'] as String? ?? '',
      currentSalary: (json['current_salary'] as num?)?.toDouble() ?? 0.0,
      targetSalary: (json['target_salary'] as num?)?.toDouble() ?? 0.0,
      debt: (json['debt'] as num?)?.toDouble() ?? 0.0,
      emergencyFund: (json['emergency_fund'] as num?)?.toDouble() ?? 0.0,
      careerApplicationsCount: json['career_applications_count'] as int? ?? 0,
      youtubeVideosUploadedCount: json['youtube_videos_uploaded_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'welcome_message': welcomeMessage,
      'daily_mission': dailyMission,
      'streak_days': streakDays,
      'daily_score': dailyScore,
      'highest_impact_task': highestImpactTask,
      'is_hit_completed': isHitCompleted,
      'current_law_insight': currentLawInsight,
      'current_salary': currentSalary,
      'target_salary': targetSalary,
      'debt': debt,
      'emergency_fund': emergencyFund,
      'career_applications_count': careerApplicationsCount,
      'youtube_videos_uploaded_count': youtubeVideosUploadedCount,
    };
  }

  @override
  List<Object?> get props => [
        welcomeMessage,
        dailyMission,
        streakDays,
        dailyScore,
        highestImpactTask,
        isHitCompleted,
        currentLawInsight,
        currentSalary,
        targetSalary,
        debt,
        emergencyFund,
        careerApplicationsCount,
        youtubeVideosUploadedCount,
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
