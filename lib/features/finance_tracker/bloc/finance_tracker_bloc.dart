import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/finance_tracker_repository.dart';
import 'finance_tracker_event.dart';
import 'finance_tracker_state.dart';

class FinanceTrackerBloc extends Bloc<FinanceTrackerEvent, FinanceTrackerState> {
  final FinanceTrackerRepository _repository;
  StreamSubscription? _settingsSub;
  StreamSubscription? _expensesSub;

  FinanceTrackerBloc(this._repository) : super(const FinanceTrackerState()) {
    on<FinanceTrackerStarted>(_onStarted);
    on<FinanceTrackerRefreshRequested>(_onRefreshRequested);
    on<FinanceTrackerSettingsUpdated>(_onSettingsUpdated);
    on<FinanceTrackerExpenseAdded>(_onExpenseAdded);
    on<FinanceTrackerExpenseDeleted>(_onExpenseDeleted);

    _settingsSub = _repository.watchSettings().listen((_) {
      add(const FinanceTrackerRefreshRequested());
    });
    _expensesSub = _repository.watchExpenses().listen((_) {
      add(const FinanceTrackerRefreshRequested());
    });
  }

  Future<void> _onStarted(
    FinanceTrackerStarted event,
    Emitter<FinanceTrackerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final settings = await _repository.getSettings();
      final expenses = await _repository.getAllExpenses();
      emit(state.copyWith(isLoading: false, settings: settings, expenses: expenses));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    FinanceTrackerRefreshRequested event,
    Emitter<FinanceTrackerState> emit,
  ) async {
    try {
      final settings = await _repository.getSettings();
      final expenses = await _repository.getAllExpenses();
      emit(state.copyWith(settings: settings, expenses: expenses));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSettingsUpdated(
    FinanceTrackerSettingsUpdated event,
    Emitter<FinanceTrackerState> emit,
  ) async {
    try {
      await _repository.updateSettings(
        salary: event.salary,
        netWorth: event.netWorth,
        debt: event.debt,
        emergencyFund: event.emergencyFund,
        emergencyFundTarget: event.emergencyFundTarget,
        savings: event.savings,
        savingsTarget: event.savingsTarget,
        netWorthHistory: event.netWorthHistory,
        netWorthMonths: event.netWorthMonths,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onExpenseAdded(
    FinanceTrackerExpenseAdded event,
    Emitter<FinanceTrackerState> emit,
  ) async {
    try {
      await _repository.addExpense(event.category, event.amount);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onExpenseDeleted(
    FinanceTrackerExpenseDeleted event,
    Emitter<FinanceTrackerState> emit,
  ) async {
    try {
      await _repository.deleteExpense(event.id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _settingsSub?.cancel();
    _expensesSub?.cancel();
    return super.close();
  }
}
