import '../models/career_tracker_model.dart';

abstract class CareerTrackerRepository {
  Future<List<CareerTrackerModel>> getAllApplications();
  Stream<String> watchChanges();
  Future<void> addApplication({
    required String company,
    required String role,
    required String status,
    required double salary,
    required bool recruiterContacted,
    String interviewDate = '',
    String notes = '',
  });
  Future<void> updateStatus(int id, String status);
  Future<void> updateApplication(CareerTrackerModel model);
  Future<void> deleteApplication(int id);
}
