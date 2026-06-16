class DashboardModel {
  final double currentSalary;
  final double goalTarget;
  final double goalCurrent;
  final String goalTitle;
  final int dailyScore;
  final int weeklyScore;

  const DashboardModel({
    required this.currentSalary,
    required this.goalTarget,
    required this.goalCurrent,
    required this.goalTitle,
    required this.dailyScore,
    required this.weeklyScore,
  });

  DashboardModel copyWith({
    double? currentSalary,
    double? goalTarget,
    double? goalCurrent,
    String? goalTitle,
    int? dailyScore,
    int? weeklyScore,
  }) {
    return DashboardModel(
      currentSalary: currentSalary ?? this.currentSalary,
      goalTarget: goalTarget ?? this.goalTarget,
      goalCurrent: goalCurrent ?? this.goalCurrent,
      goalTitle: goalTitle ?? this.goalTitle,
      dailyScore: dailyScore ?? this.dailyScore,
      weeklyScore: weeklyScore ?? this.weeklyScore,
    );
  }
}
