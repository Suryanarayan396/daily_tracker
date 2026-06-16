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
        salary: 75000.0,
        netWorth: 450000.0,
        debt: 45000.0,
        emergencyFund: 120000.0,
        emergencyFundTarget: 200000.0,
        savings: 85000.0,
        savingsTarget: 150000.0,
        netWorthHistory: const [380000.0, 395000.0, 410000.0, 422000.0, 435000.0, 450000.0],
        netWorthMonths: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
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
    final maps = await _db.query('expense_items', orderBy: 'id DESC');
    if (maps.isEmpty) {
      final defaults = [
        const ExpenseItemModel(id: 0, category: 'Rent', amount: 18000.0),
        const ExpenseItemModel(id: 0, category: 'Groceries', amount: 8500.0),
        const ExpenseItemModel(id: 0, category: 'Utilities', amount: 4200.0),
        const ExpenseItemModel(id: 0, category: 'Transport', amount: 3500.0),
        const ExpenseItemModel(id: 0, category: 'Entertainment', amount: 6000.0),
      ];

      for (final item in defaults) {
        await _db.insert(
          'expense_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      SqliteService.notify('expense_items');
      return getAllExpenses();
    }

    return maps.map((map) => ExpenseItemModel.fromMap(map)).toList();
  }

  @override
  Stream<String> watchExpenses() {
    return SqliteService.watchTable('expense_items');
  }

  @override
  Future<void> addExpense(String category, double amount) async {
    final item = ExpenseItemModel(id: 0, category: category, amount: amount);
    await _db.insert(
      'expense_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
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
