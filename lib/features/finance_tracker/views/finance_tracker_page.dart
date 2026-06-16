import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../bloc/finance_tracker_bloc.dart';
import '../bloc/finance_tracker_event.dart';
import '../bloc/finance_tracker_state.dart';

class FinanceTrackerPage extends StatelessWidget {
  const FinanceTrackerPage({super.key});

  void _showUpdateFinanceDialog(BuildContext context, FinanceTrackerState state) {
    final settings = state.settings;
    final salaryCtrl = TextEditingController(text: settings?.salary.toStringAsFixed(0) ?? '0');
    final savingsCtrl = TextEditingController(text: settings?.savings.toStringAsFixed(0) ?? '0');
    final debtCtrl = TextEditingController(text: settings?.debt.toStringAsFixed(0) ?? '0');
    final emergencyCtrl = TextEditingController(text: settings?.emergencyFund.toStringAsFixed(0) ?? '0');
    final netWorthCtrl = TextEditingController(text: settings?.netWorth.toStringAsFixed(0) ?? '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + ctx.screenHeight * 0.03,
          left: ctx.screenWidth * 0.05,
          right: ctx.screenWidth * 0.05,
          top: ctx.screenHeight * 0.03,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: ctx.screenWidth * 0.12, height: 4,
                  decoration: BoxDecoration(color: ctx.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: ctx.screenHeight * 0.02),
              Text('Update Finances', style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: ctx.screenHeight * 0.025),
              _inputField(ctx, salaryCtrl, 'Monthly Salary (₹)', Icons.payments_rounded),
              SizedBox(height: ctx.screenHeight * 0.016),
              _inputField(ctx, savingsCtrl, 'Liquid Savings (₹)', Icons.savings_rounded),
              SizedBox(height: ctx.screenHeight * 0.016),
              _inputField(ctx, debtCtrl, 'Current Debt (₹)', Icons.credit_card_rounded),
              SizedBox(height: ctx.screenHeight * 0.016),
              _inputField(ctx, emergencyCtrl, 'Emergency Fund (₹)', Icons.health_and_safety_rounded),
              SizedBox(height: ctx.screenHeight * 0.016),
              _inputField(ctx, netWorthCtrl, 'Net Worth (₹)', Icons.account_balance_rounded),
              SizedBox(height: ctx.screenHeight * 0.025),
              SizedBox(
                width: double.infinity,
                height: ctx.screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<FinanceTrackerBloc>().add(FinanceTrackerSettingsUpdated(
                      salary: double.tryParse(salaryCtrl.text) ?? settings?.salary,
                      netWorth: double.tryParse(netWorthCtrl.text) ?? settings?.netWorth,
                      debt: double.tryParse(debtCtrl.text) ?? settings?.debt,
                      emergencyFund: double.tryParse(emergencyCtrl.text) ?? settings?.emergencyFund,
                      savings: double.tryParse(savingsCtrl.text) ?? settings?.savings,
                    ));
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ctx.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final categoryCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Add Expense Item', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: Icon(Icons.payments_rounded, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final cat = categoryCtrl.text.trim();
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (cat.isNotEmpty && amt > 0) {
                context.read<FinanceTrackerBloc>().add(FinanceTrackerExpenseAdded(category: cat, amount: amt));
                HapticFeedback.mediumImpact();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Widget _inputField(BuildContext ctx, TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceTrackerBloc, FinanceTrackerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AppLoader();
        }
        if (state.errorMessage != null && state.settings == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.screenWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: context.colorScheme.error, size: AppSizes.icon48),
                  SizedBox(height: context.screenHeight * 0.02),
                  Text(state.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: context.colorScheme.error)),
                ],
              ),
            ),
          );
        }

        final settings = state.settings;
        if (settings == null) {
          return const AppLoader();
        }

        final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
        final totalDebtScale = 250000.0;
        final debtPercent = (1.0 - (settings.debt / totalDebtScale)).clamp(0.0, 1.0);
        final totalExpenses = state.totalExpenses;
        final expenseRatio = settings.salary > 0 ? (totalExpenses / settings.salary).clamp(0.0, 1.5) : 0.0;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenWidth * 0.05,
                vertical: context.screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Finance Ledger',
                          style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: context.screenHeight * 0.005),
                      Text('Shield your assets against Murphy\'s Law.',
                          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                    ]),
                    IconButton(
                      onPressed: () => _showUpdateFinanceDialog(context, state),
                      style: IconButton.styleFrom(
                        backgroundColor: context.colorScheme.surface, foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(AppSizes.padding12),
                        side: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                  ]),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Net Worth Hero ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.screenWidth * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colorScheme.primary.withOpacity(0.15), context.colorScheme.surface],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.br16),
                      border: Border.all(color: context.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('TOTAL NET WORTH', style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        Icon(Icons.shield_rounded, color: context.colorScheme.primary, size: AppSizes.icon20),
                      ]),
                      SizedBox(height: context.screenHeight * 0.01),
                      Text(fmt.format(settings.netWorth),
                          style: context.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: context.screenHeight * 0.012),
                      _NetWorthMiniChart(history: settings.netWorthHistory, months: settings.netWorthMonths),
                    ]),
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Salary + Expenses Row ──────────────────────────────
                  Row(children: [
                    Expanded(child: _heroMetricCard(
                      context,
                      label: 'Monthly Salary',
                      value: fmt.format(settings.salary),
                      icon: Icons.payments_rounded,
                      color: context.colorScheme.secondary,
                    )),
                    SizedBox(width: context.screenWidth * 0.03),
                    Expanded(child: _heroMetricCard(
                      context,
                      label: 'Total Expenses',
                      value: fmt.format(totalExpenses),
                      icon: Icons.receipt_long_rounded,
                      color: context.colorScheme.error,
                      subtitle: '${(expenseRatio * 100).toStringAsFixed(0)}% of salary',
                    )),
                  ]),
                  SizedBox(height: context.screenHeight * 0.02),

                  // ── Savings + Emergency ────────────────────────────────
                  Row(children: [
                    Expanded(child: AppCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Savings', style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Icon(Icons.savings_rounded, color: context.colorScheme.primary, size: AppSizes.icon16),
                        ]),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text(fmt.format(settings.savings),
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: context.screenHeight * 0.012),
                        LinearProgressIndicator(
                          value: state.savingsPercent,
                          backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                          color: context.colorScheme.primary,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        SizedBox(height: 4),
                        Text('Target: ${fmt.format(settings.savingsTarget)}',
                            style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                      ]),
                    )),
                    SizedBox(width: context.screenWidth * 0.03),
                    Expanded(child: AppCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Emergency', style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Icon(Icons.health_and_safety_rounded, color: context.colorScheme.secondary, size: AppSizes.icon16),
                        ]),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text(fmt.format(settings.emergencyFund),
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: context.screenHeight * 0.012),
                        LinearProgressIndicator(
                          value: state.emergencyPercent,
                          backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                          color: context.colorScheme.secondary,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        SizedBox(height: 4),
                        Text('Target: ${fmt.format(settings.emergencyFundTarget)}',
                            style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                      ]),
                    )),
                  ]),
                  SizedBox(height: context.screenHeight * 0.02),

                  // ── Debt Card ──────────────────────────────────────────
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Debt Clearance', style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colorScheme.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(fmt.format(settings.debt),
                              style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.error, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      SizedBox(height: context.screenHeight * 0.015),
                      LinearProgressIndicator(
                        value: debtPercent,
                        backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                        color: context.colorScheme.error,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      SizedBox(height: context.screenHeight * 0.008),
                      Text('${(debtPercent * 100).toStringAsFixed(0)}% debt-free capacity remaining',
                          style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                    ]),
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Monthly Expense Breakdown ──────────────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Monthly Expense Breakdown',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      onPressed: () => _showAddExpenseDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                    ),
                  ]),
                  SizedBox(height: context.screenHeight * 0.015),
                  AppCard(
                    child: Column(
                      children: state.expenses.map((expense) {
                        final ratio = totalExpenses > 0 ? (expense.amount / totalExpenses) : 0.0;
                        final colors = [
                          context.colorScheme.primary,
                          context.colorScheme.secondary,
                          context.colorScheme.tertiary,
                          context.colorScheme.error,
                          const Color(0xFFF59E0B),
                        ];
                        final idx = state.expenses.indexOf(expense);
                        final barColor = colors[idx % colors.length];
                        return Padding(
                          padding: EdgeInsets.only(bottom: context.screenHeight * 0.015),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Row(children: [
                                Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w500)),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.only(left: 8),
                                  icon: Icon(Icons.delete_outline_rounded, color: context.colorScheme.error.withOpacity(0.7), size: 16),
                                  onPressed: () {
                                    context.read<FinanceTrackerBloc>().add(FinanceTrackerExpenseDeleted(id: expense.id));
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                              ]),
                              Text(
                                '${fmt.format(expense.amount)} (${(ratio * 100).toStringAsFixed(0)}%)',
                                style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                              ),
                            ]),
                            SizedBox(height: context.screenHeight * 0.006),
                            LinearProgressIndicator(
                              value: ratio,
                              backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                              color: barColor,
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ]),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.05),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _heroMetricCard(BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
          Icon(icon, color: color, size: AppSizes.icon16),
        ]),
        SizedBox(height: context.screenHeight * 0.006),
        Text(value, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        if (subtitle != null) ...[
          SizedBox(height: 2),
          Text(subtitle, style: context.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ]),
    );
  }
}

class _NetWorthMiniChart extends StatelessWidget {
  final List<double> history;
  final List<String> months;

  const _NetWorthMiniChart({required this.history, required this.months});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();
    final maxVal = history.reduce((a, b) => a > b ? a : b);
    final chartHeight = context.screenHeight * 0.07;

    return SizedBox(
      height: chartHeight + 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(history.length, (i) {
          final ratio = maxVal > 0 ? (history[i] / maxVal) : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: context.screenWidth * 0.08,
                height: chartHeight * ratio.clamp(0.1, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colorScheme.primary, context.colorScheme.primary.withOpacity(0.4)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 4),
              Text(i < months.length ? months[i] : '',
                  style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            ],
          );
        }),
      ),
    );
  }
}
