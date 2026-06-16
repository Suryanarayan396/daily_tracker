import 'package:sqflite/sqflite.dart';
import '../../../core/services/sqlite_service.dart';
import '../models/career_tracker_model.dart';
import 'career_tracker_repository.dart';

class CareerTrackerRepositoryImpl implements CareerTrackerRepository {
  const CareerTrackerRepositoryImpl();

  Database get _db => SqliteService.db;

  @override
  Future<List<CareerTrackerModel>> getAllApplications() async {
    final maps = await _db.query('job_applications', orderBy: 'dateApplied DESC');
    return maps.map((map) => CareerTrackerModel.fromMap(map)).toList();
  }

  Future<CareerTrackerModel?> getById(int id) async {
    final maps = await _db.query(
      'job_applications',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CareerTrackerModel.fromMap(maps.first);
  }

  @override
  Stream<String> watchChanges() {
    return SqliteService.watchTable('job_applications');
  }

  @override
  Future<void> addApplication({
    required String company,
    required String role,
    required String status,
    required double salary,
    required bool recruiterContacted,
    String interviewDate = '',
    String notes = '',
  }) async {
    final model = CareerTrackerModel(
      id: 0,
      company: company,
      role: role,
      status: status,
      salary: salary,
      dateApplied: DateTime.now(),
      recruiterContacted: recruiterContacted,
      interviewDate: interviewDate,
      notes: notes,
    );

    await _db.insert(
      'job_applications',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    SqliteService.notify('job_applications');
  }

  @override
  Future<void> updateStatus(int id, String status) async {
    final model = await getById(id);
    if (model == null) return;
    
    final updated = CareerTrackerModel(
      id: model.id,
      company: model.company,
      role: model.role,
      status: status,
      salary: model.salary,
      dateApplied: model.dateApplied,
      recruiterContacted: model.recruiterContacted,
      interviewDate: model.interviewDate,
      notes: model.notes,
    );

    await _db.update(
      'job_applications',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('job_applications');
  }

  @override
  Future<void> updateApplication(CareerTrackerModel model) async {
    await _db.update(
      'job_applications',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
    SqliteService.notify('job_applications');
  }

  @override
  Future<void> deleteApplication(int id) async {
    await _db.delete(
      'job_applications',
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('job_applications');
  }
}
