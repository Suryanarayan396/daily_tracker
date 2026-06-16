import '../models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboardData();
  Future<void> updateHit(String task);
  Future<void> toggleHit();
  Future<void> rotateInsight();
}
