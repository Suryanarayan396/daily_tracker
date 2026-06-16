import '../models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboardData();
  Future<void> updateSalary(double salary);
  Future<void> updateGoalProgress(double progress);
  Future<void> incrementDailyScore();
}
