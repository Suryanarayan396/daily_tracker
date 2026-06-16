import '../../../core/services/life_os_repository.dart';
import '../models/dashboard_model.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final LifeOSRepository _sharedRepo = LifeOSRepository();

  @override
  Future<DashboardModel> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DashboardModel(
      currentSalary: _sharedRepo.currentSalary,
      goalTitle: _sharedRepo.highestImpactTask,
      goalTarget: 1.0,
      goalCurrent: _sharedRepo.isHitCompleted ? 1.0 : 0.0,
      dailyScore: _sharedRepo.dailyScore,
      weeklyScore: 620 + (_sharedRepo.isHitCompleted ? 15 : 0),
    );
  }

  @override
  Future<void> updateSalary(double salary) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sharedRepo.updateSalary(salary);
  }

  @override
  Future<void> updateGoalProgress(double progress) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if ((progress >= 1.0 && !_sharedRepo.isHitCompleted) || 
        (progress < 1.0 && _sharedRepo.isHitCompleted)) {
      _sharedRepo.toggleHit();
    }
  }

  @override
  Future<void> incrementDailyScore() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sharedRepo.toggleHit();
  }
}

