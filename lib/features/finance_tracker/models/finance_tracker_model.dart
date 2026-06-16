import 'package:equatable/equatable.dart';

class FinanceSettingsModel extends Equatable {
  final int id;
  final double salary;
  final double netWorth;
  final double debt;
  final double emergencyFund;
  final double emergencyFundTarget;
  final double savings;
  final double savingsTarget;
  final List<double> netWorthHistory;
  final List<String> netWorthMonths;

  const FinanceSettingsModel({
    this.id = 1,
    required this.salary,
    required this.netWorth,
    required this.debt,
    required this.emergencyFund,
    required this.emergencyFundTarget,
    required this.savings,
    required this.savingsTarget,
    required this.netWorthHistory,
    required this.netWorthMonths,
  });

  FinanceSettingsModel copyWith({
    int? id,
    double? salary,
    double? netWorth,
    double? debt,
    double? emergencyFund,
    double? emergencyFundTarget,
    double? savings,
    double? savingsTarget,
    List<double>? netWorthHistory,
    List<String>? netWorthMonths,
  }) {
    return FinanceSettingsModel(
      id: id ?? this.id,
      salary: salary ?? this.salary,
      netWorth: netWorth ?? this.netWorth,
      debt: debt ?? this.debt,
      emergencyFund: emergencyFund ?? this.emergencyFund,
      emergencyFundTarget: emergencyFundTarget ?? this.emergencyFundTarget,
      savings: savings ?? this.savings,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      netWorthHistory: netWorthHistory ?? this.netWorthHistory,
      netWorthMonths: netWorthMonths ?? this.netWorthMonths,
    );
  }

  factory FinanceSettingsModel.fromJson(Map<String, dynamic> json) {
    return FinanceSettingsModel(
      id: json['id'] as int? ?? 1,
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0.0,
      debt: (json['debt'] as num?)?.toDouble() ?? 0.0,
      emergencyFund: (json['emergency_fund'] as num?)?.toDouble() ?? 0.0,
      emergencyFundTarget: (json['emergency_fund_target'] as num?)?.toDouble() ?? 0.0,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      savingsTarget: (json['savings_target'] as num?)?.toDouble() ?? 0.0,
      netWorthHistory: (json['net_worth_history'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? const [],
      netWorthMonths: (json['net_worth_months'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salary': salary,
      'net_worth': netWorth,
      'debt': debt,
      'emergency_fund': emergencyFund,
      'emergency_fund_target': emergencyFundTarget,
      'savings': savings,
      'savings_target': savingsTarget,
      'net_worth_history': netWorthHistory,
      'net_worth_months': netWorthMonths,
    };
  }

  factory FinanceSettingsModel.fromMap(Map<String, dynamic> map) {
    final historyStr = map['netWorthHistory'] as String? ?? '';
    final monthsStr = map['netWorthMonths'] as String? ?? '';

    return FinanceSettingsModel(
      id: map['id'] as int? ?? 1,
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      netWorth: (map['netWorth'] as num?)?.toDouble() ?? 0.0,
      debt: (map['debt'] as num?)?.toDouble() ?? 0.0,
      emergencyFund: (map['emergencyFund'] as num?)?.toDouble() ?? 0.0,
      emergencyFundTarget: (map['emergencyFundTarget'] as num?)?.toDouble() ?? 0.0,
      savings: (map['savings'] as num?)?.toDouble() ?? 0.0,
      savingsTarget: (map['savingsTarget'] as num?)?.toDouble() ?? 0.0,
      netWorthHistory: historyStr.isNotEmpty
          ? historyStr.split(',').map((s) => double.tryParse(s) ?? 0.0).toList()
          : const [],
      netWorthMonths: monthsStr.isNotEmpty ? monthsStr.split(',') : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'salary': salary,
      'netWorth': netWorth,
      'debt': debt,
      'emergencyFund': emergencyFund,
      'emergencyFundTarget': emergencyFundTarget,
      'savings': savings,
      'savingsTarget': savingsTarget,
      'netWorthHistory': netWorthHistory.join(','),
      'netWorthMonths': netWorthMonths.join(','),
    };
  }

  @override
  List<Object?> get props => [
        id,
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

class ExpenseItemModel extends Equatable {
  final int id;
  final String category;
  final double amount;

  const ExpenseItemModel({
    required this.id,
    required this.category,
    required this.amount,
  });

  ExpenseItemModel copyWith({
    int? id,
    String? category,
    double? amount,
  }) {
    return ExpenseItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
    );
  }

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseItemModel(
      id: json['id'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'category': category,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    };
  }

  factory ExpenseItemModel.fromMap(Map<String, dynamic> map) {
    return ExpenseItemModel(
      id: map['id'] as int? ?? 0,
      category: map['category'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, category, amount];
}
