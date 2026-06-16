import 'dart:async';

// MODEL DEFINITIONS

class JobApplication {
  final String id;
  final String company;
  final String role;
  final String status; // 'Applied', 'Screening', 'Technical', 'Final', 'Offer', 'Rejected'
  final double salary;
  final DateTime dateApplied;

  JobApplication({
    required this.id,
    required this.company,
    required this.role,
    required this.status,
    required this.salary,
    required this.dateApplied,
  });

  JobApplication copyWith({
    String? id,
    String? company,
    String? role,
    String? status,
    double? salary,
    DateTime? dateApplied,
  }) {
    return JobApplication(
      id: id ?? this.id,
      company: company ?? this.company,
      role: role ?? this.role,
      status: status ?? this.status,
      salary: salary ?? this.salary,
      dateApplied: dateApplied ?? this.dateApplied,
    );
  }
}

class ExpenseItem {
  final String category;
  final double amount;
  ExpenseItem({required this.category, required this.amount});
}

class SkillProgress {
  final String name;
  final double progress; // 0.0 to 1.0
  SkillProgress({required this.name, required this.progress});
}

class LearningMilestone {
  final String title;
  final bool isCompleted;
  LearningMilestone({required this.title, required this.isCompleted});
}

class ReflectionData {
  final String murphy;
  final String pareto;
  final String gilbert;
  final String occam;
  final String parkinson;
  final String hanlon;
  final String peter;
  final DateTime date;
  final int score;

  ReflectionData({
    required this.murphy,
    required this.pareto,
    required this.gilbert,
    required this.occam,
    required this.parkinson,
    required this.hanlon,
    required this.peter,
    required this.date,
    required this.score,
  });

  bool get isEmpty =>
      murphy.isEmpty &&
      pareto.isEmpty &&
      gilbert.isEmpty &&
      occam.isEmpty &&
      parkinson.isEmpty &&
      hanlon.isEmpty &&
      peter.isEmpty;
}

// LIFEOS REPOSITORY DEFINITION

class LifeOSRepository {
  // Singleton pattern
  static final LifeOSRepository _instance = LifeOSRepository._internal();
  factory LifeOSRepository() => _instance;
  LifeOSRepository._internal();

  final _changeController = StreamController<void>.broadcast();
  Stream<void> get onChange => _changeController.stream;

  // 1. Dashboard State
  String welcomeMessage = "Hello, Ambitious Developer!";
  String dailyMission = "Optimize the 20% that drives 80% of your career growth.";
  int streakDays = 5;
  double currentSalary = 5500.0;
  double targetSalary = 10000.0;
  double debt = 12000.0;
  double emergencyFund = 15000.0;
  double emergencyFundTarget = 25000.0;
  int dailyScore = 85;
  String highestImpactTask = "Design LifeOS component architecture";
  bool isHitCompleted = false;
  String currentLawInsight = "Work expands to fill the time available. Set a 2-hour deadline for your next coding session. (Parkinson's Law)";

  // 2. Career Tracker State
  List<JobApplication> applications = [
    JobApplication(id: '1', company: 'Google', role: 'L5 Flutter Dev', status: 'Technical', salary: 11000, dateApplied: DateTime.now().subtract(const Duration(days: 5))),
    JobApplication(id: '2', company: 'Stripe', role: 'Senior Mobile Architect', status: 'Screening', salary: 12500, dateApplied: DateTime.now().subtract(const Duration(days: 12))),
    JobApplication(id: '3', company: 'Netflix', role: 'UI Engineer', status: 'Offer', salary: 13000, dateApplied: DateTime.now().subtract(const Duration(days: 20))),
    JobApplication(id: '4', company: 'Tome', role: 'Full Stack Developer', status: 'Applied', salary: 9000, dateApplied: DateTime.now().subtract(const Duration(days: 1))),
  ];

  // 3. Finance Tracker State
  double netWorth = 48000.0; // assets - liabilities
  List<ExpenseItem> expenses = [
    ExpenseItem(category: 'Housing', amount: 1800),
    ExpenseItem(category: 'Food', amount: 600),
    ExpenseItem(category: 'Learning', amount: 300),
    ExpenseItem(category: 'Transport', amount: 200),
    ExpenseItem(category: 'Leisure', amount: 300),
  ];

  // 4. Learning Tracker State
  String currentLearningFocus = "Mastering Flutter Micro-interactions & State Management";
  List<SkillProgress> skills = [
    SkillProgress(name: 'Flutter', progress: 0.75),
    SkillProgress(name: 'System Design', progress: 0.60),
    SkillProgress(name: 'Backend', progress: 0.50),
    SkillProgress(name: 'AI Tools', progress: 0.85),
  ];
  List<double> weeklyLearningHours = [2.5, 1.5, 3.0, 0.5, 2.0, 4.0, 1.0];
  int learningStreak = 12;
  List<LearningMilestone> milestones = [
    LearningMilestone(title: 'Build state management skeleton', isCompleted: true),
    LearningMilestone(title: 'Integrate custom charts using CustomPainter', isCompleted: true),
    LearningMilestone(title: 'Implement reflection scoring and local cache', isCompleted: false),
  ];

  // 5. Daily Reflection State
  ReflectionData currentReflection = ReflectionData(
    murphy: '',
    pareto: '',
    gilbert: '',
    occam: '',
    parkinson: '',
    hanlon: '',
    peter: '',
    date: DateTime.now(),
    score: 0,
  );

  // UPDATE METHODS

  void updateSalary(double val) {
    currentSalary = val;
    netWorth = (15000 + 33000) - debt + val * 0.5; // adjust net worth slightly
    _notify();
  }

  void updateTargetSalary(double val) {
    targetSalary = val;
    _notify();
  }

  void updateDebt(double val) {
    debt = val;
    _notify();
  }

  void updateEmergencyFund(double val) {
    emergencyFund = val;
    _notify();
  }

  void toggleHit() {
    isHitCompleted = !isHitCompleted;
    if (isHitCompleted) {
      dailyScore = (dailyScore + 15).clamp(0, 100);
    } else {
      dailyScore = (dailyScore - 15).clamp(0, 100);
    }
    _notify();
  }

  void updateHit(String task) {
    highestImpactTask = task;
    isHitCompleted = false;
    _notify();
  }

  void addJobApplication(String company, String role, double salary, String status) {
    applications.insert(
      0,
      JobApplication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        company: company,
        role: role,
        status: status,
        salary: salary,
        dateApplied: DateTime.now(),
      ),
    );
    dailyScore = (dailyScore + 10).clamp(0, 100);
    _notify();
  }

  void updateJobApplicationStatus(String id, String status) {
    final idx = applications.indexWhere((app) => app.id == id);
    if (idx != -1) {
      applications[idx] = applications[idx].copyWith(status: status);
      _notify();
    }
  }

  void updateReflection(ReflectionData ref) {
    currentReflection = ref;
    dailyScore = (40 + ref.score * 0.6).round().clamp(0, 100); // 40 base + reflections
    if (ref.score > 0) {
      streakDays = 6; // increment or lock streak
    }
    _notify();
  }

  void addLearningSession(double hours, String skillName) {
    final todayWeekday = DateTime.now().weekday - 1; // 0 for Monday, 6 for Sunday
    if (todayWeekday >= 0 && todayWeekday < weeklyLearningHours.length) {
      weeklyLearningHours[todayWeekday] += hours;
    }
    
    // Increment skill progress
    final idx = skills.indexWhere((sk) => sk.name.toLowerCase() == skillName.toLowerCase());
    if (idx != -1) {
      double newProg = (skills[idx].progress + (hours * 0.02)).clamp(0.0, 1.0);
      skills[idx] = SkillProgress(name: skills[idx].name, progress: newProg);
    }

    dailyScore = (dailyScore + (hours * 5).toInt()).clamp(0, 100);
    _notify();
  }

  void toggleMilestone(int index) {
    if (index >= 0 && index < milestones.length) {
      milestones[index] = LearningMilestone(
        title: milestones[index].title,
        isCompleted: !milestones[index].isCompleted,
      );
      _notify();
    }
  }

  void addMilestone(String title) {
    milestones.add(LearningMilestone(title: title, isCompleted: false));
    _notify();
  }

  void changeLearningFocus(String focus) {
    currentLearningFocus = focus;
    _notify();
  }

  void updateFinance(double newNetWorth, double newDebt, double newEmergencyFund) {
    netWorth = newNetWorth;
    debt = newDebt;
    emergencyFund = newEmergencyFund;
    _notify();
  }

  void rotateInsight() {
    final insights = [
      "Work expands to fill the time available. Set a 2-hour deadline for your next coding session. (Parkinson's Law)",
      "What could go wrong, will go wrong. Back up your repository and write unit tests for critical paths. (Murphy's Law)",
      "80% of results come from 20% of efforts. Double down on your core feature instead of minor visual tweaks. (Pareto Principle)",
      "The biggest problem is that no one tells you what to do. Clearly define your tasks for today. (Gilbert's Law)",
      "The simplest solution is usually the correct one. Refactor that complex nested class into smaller widgets. (Occam's Razor)",
      "Never attribute to malice that which is adequately explained by ignorance. Give your team member the benefit of doubt. (Hanlon's Razor)",
      "In a hierarchy, people rise to their level of incompetence. Switch from passive reading to coding to keep growing. (Peter Principle)"
    ];
    final currentIdx = insights.indexOf(currentLawInsight);
    currentLawInsight = insights[(currentIdx + 1) % insights.length];
    _notify();
  }

  void _notify() {
    _changeController.add(null);
  }
}
