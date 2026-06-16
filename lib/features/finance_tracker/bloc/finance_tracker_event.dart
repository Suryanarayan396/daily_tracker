import 'package:equatable/equatable.dart';

sealed class FinanceTrackerEvent extends Equatable {
  const FinanceTrackerEvent();

  @override
  List<Object?> get props => [];
}

final class FinanceTrackerStarted extends FinanceTrackerEvent {
  const FinanceTrackerStarted();
}

final class FinanceTrackerRefreshRequested extends FinanceTrackerEvent {
  const FinanceTrackerRefreshRequested();
}

final class FinanceTrackerSettingsUpdated extends FinanceTrackerEvent {
  final double? salary;
  final double? netWorth;
  final double? debt;
  final double? emergencyFund;
  final double? emergencyFundTarget;
  final double? savings;
  final double? savingsTarget;
  final List<double>? netWorthHistory;
  final List<String>? netWorthMonths;

  const FinanceTrackerSettingsUpdated({
    this.salary,
    this.netWorth,
    this.debt,
    this.emergencyFund,
    this.emergencyFundTarget,
    this.savings,
    this.savingsTarget,
    this.netWorthHistory,
    this.netWorthMonths,
  });

  @override
  List<Object?> get props => [
        salary,
        netWorth,
        debt,
        emergencyFund,
        emergencyFundTarget,
        savings,
        savingsTarget,
        netWorthHistory,
        netWorthMonths,
      ];
}

final class FinanceTrackerExpenseAdded extends FinanceTrackerEvent {
  final String category;
  final double amount;

  const FinanceTrackerExpenseAdded({required this.category, required this.amount});

  @override
  List<Object?> get props => [category, amount];
}

final class FinanceTrackerExpenseDeleted extends FinanceTrackerEvent {
  final int id;

  const FinanceTrackerExpenseDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}
