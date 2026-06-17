import 'package:sqflite/sqflite.dart';
import '../../../core/services/sqlite_service.dart';
import '../models/finance_tracker_model.dart';
import 'finance_tracker_repository.dart';

class FinanceTrackerRepositoryImpl implements FinanceTrackerRepository {
  const FinanceTrackerRepositoryImpl();

  Database get _db => SqliteService.db;

  @override
  Future<FinanceSettingsModel> getSettings() async {
    final maps = await _db.query(
      'finance_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      final settings = FinanceSettingsModel(
        id: 1,
        salary: 0.0,
        netWorth: 0.0,
        debt: 0.0,
        emergencyFund: 0.0,
        emergencyFundTarget: 0.0,
        savings: 0.0,
        savingsTarget: 0.0,
        netWorthHistory: const [],
        netWorthMonths: const [],
      );

      await _db.insert(
        'finance_settings',
        settings.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return settings;
    }

    return FinanceSettingsModel.fromMap(maps.first);
  }

  @override
  Stream<String> watchSettings() {
    return SqliteService.watchTable('finance_settings');
  }

  @override
  Future<void> updateSettings({
    double? salary,
    double? netWorth,
    double? debt,
    double? emergencyFund,
    double? emergencyFundTarget,
    double? savings,
    double? savingsTarget,
    List<double>? netWorthHistory,
    List<String>? netWorthMonths,
  }) async {
    final settings = await getSettings();
    final updated = settings.copyWith(
      salary: salary,
      netWorth: netWorth,
      debt: debt,
      emergencyFund: emergencyFund,
      emergencyFundTarget: emergencyFundTarget,
      savings: savings,
      savingsTarget: savingsTarget,
      netWorthHistory: netWorthHistory,
      netWorthMonths: netWorthMonths,
    );

    await _db.update(
      'finance_settings',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
    SqliteService.notify('finance_settings');
  }

  @override
  Future<List<ExpenseItemModel>> getAllExpenses() async {
    final maps = await _db.query('expense_items', orderBy: 'date DESC');
    return maps.map((map) => ExpenseItemModel.fromMap(map)).toList();
  }

  @override
  Stream<String> watchExpenses() {
    return SqliteService.watchTable('expense_items');
  }

  @override
  Future<void> addExpense({
    required String category,
    required String description,
    required double amount,
    required DateTime date,
  }) async {
    final item = ExpenseItemModel(
      id: 0,
      category: category,
      description: description,
      amount: amount,
      date: date,
    );
    await _db.insert(
      'expense_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    SqliteService.notify('expense_items');
  }

  @override
  Future<void> updateExpense(ExpenseItemModel expense) async {
    await _db.update(
      'expense_items',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    SqliteService.notify('expense_items');
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _db.delete(
      'expense_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    SqliteService.notify('expense_items');
  }
}
