import 'package:equatable/equatable.dart';
import '../models/finance_tracker_model.dart';

class FinanceTrackerState extends Equatable {
  const FinanceTrackerState({
    this.isLoading = false,
    this.settings,
    this.expenses = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final FinanceSettingsModel? settings;
  final List<ExpenseItemModel> expenses;
  final String? errorMessage;

  double get totalExpenses => expenses.fold(0.0, (sum, item) => sum + item.amount);
  double get remainingIncome => (settings?.salary ?? 0.0) - totalExpenses;
  double get savingsPercent => (settings?.savingsTarget ?? 0.0) > 0
      ? ((settings?.savings ?? 0.0) / settings!.savingsTarget).clamp(0.0, 1.0)
      : 0.0;
  double get emergencyPercent => (settings?.emergencyFundTarget ?? 0.0) > 0
      ? ((settings?.emergencyFund ?? 0.0) / settings!.emergencyFundTarget).clamp(0.0, 1.0)
      : 0.0;

  FinanceTrackerState copyWith({
    bool? isLoading,
    FinanceSettingsModel? settings,
    List<ExpenseItemModel>? expenses,
    String? errorMessage,
  }) {
    return FinanceTrackerState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, settings, expenses, errorMessage];
}
