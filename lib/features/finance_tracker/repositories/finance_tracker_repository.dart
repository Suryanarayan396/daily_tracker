import '../models/finance_tracker_model.dart';

abstract class FinanceTrackerRepository {
  Future<FinanceSettingsModel> getSettings();
  Stream<String> watchSettings();
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
  });

  Future<List<ExpenseItemModel>> getAllExpenses();
  Stream<String> watchExpenses();
  Future<void> addExpense(String category, double amount);
  Future<void> deleteExpense(int id);
}
