import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/life_os_repository.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/repository_observer.dart';

class FinanceTrackerPage extends StatelessWidget {
  const FinanceTrackerPage({super.key});

  void _showUpdateFinanceDialog(BuildContext context, LifeOSRepository repo) {
    final netWorthCtrl = TextEditingController(text: repo.netWorth.toStringAsFixed(0));
    final debtCtrl = TextEditingController(text: repo.debt.toStringAsFixed(0));
    final emergencyCtrl = TextEditingController(text: repo.emergencyFund.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + context.screenHeight * 0.03,
            left: context.screenWidth * 0.05,
            right: context.screenWidth * 0.05,
            top: context.screenHeight * 0.03,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.screenWidth * 0.12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              Text(
                'Update Financial Balances',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),
              TextField(
                controller: netWorthCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Net Worth (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              TextField(
                controller: debtCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Current Debt (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              TextField(
                controller: emergencyCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Emergency Fund Savings (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: context.screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    final netWorthVal = double.tryParse(netWorthCtrl.text) ?? repo.netWorth;
                    final debtVal = double.tryParse(debtCtrl.text) ?? repo.debt;
                    final emergencyVal = double.tryParse(emergencyCtrl.text) ?? repo.emergencyFund;

                    repo.updateFinance(netWorthVal, debtVal, emergencyVal);
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.br12),
                    ),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryObserver(
      builder: (context, repo) {
        final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

        // Emergency fund progress (Saved vs Target)
        final emergencyPercent = (repo.emergencyFund / repo.emergencyFundTarget).clamp(0.0, 1.0);
        // Debt progress (assume total debt capacity is $25k, we show remaining capacity)
        final totalDebtScale = 25000.0;
        final debtPercent = (1.0 - (repo.debt / totalDebtScale)).clamp(0.0, 1.0);

        // Calculate health score: Higher net worth + high emergency fund relative to target - debt
        int healthScore = 80;
        if (repo.debt > 15000) healthScore -= 15;
        if (repo.emergencyFund > 10000) healthScore += 10;
        healthScore = healthScore.clamp(0, 100);

        Color healthColor = context.colorScheme.error;
        String healthStatus = "Critical State";
        if (healthScore >= 80) {
          healthColor = context.colorScheme.secondary;
          healthStatus = "Secure Portfolio";
        } else if (healthScore >= 50) {
          healthColor = context.colorScheme.tertiary;
          healthStatus = "Stable Path";
        }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finance Ledger',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.005),
                          Text(
                            'Shield your assets against Murphy\'s Law.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _showUpdateFinanceDialog(context, repo),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colorScheme.surface,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(AppSizes.padding12),
                          side: BorderSide(
                            color: context.colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // Net Worth Highlight Card (Large, glassy)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.screenWidth * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colorScheme.primary.withOpacity(0.15),
                          context.colorScheme.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.br16),
                      border: Border.all(
                        color: context.colorScheme.primary.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL NET WORTH',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Icon(Icons.shield_rounded, color: context.colorScheme.primary, size: AppSizes.icon20),
                          ],
                        ),
                        SizedBox(height: context.screenHeight * 0.01),
                        Text(
                          currencyFormat.format(repo.netWorth),
                          style: context.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.008),
                        Text(
                          'Primary Shield Strength: $healthScore% ($healthStatus)',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: healthColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Debt & Emergency Fund Double Progress Cards
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Debt Free',
                                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.remove_circle_outline_rounded, color: context.colorScheme.error, size: AppSizes.icon16),
                                ],
                              ),
                              SizedBox(height: context.screenHeight * 0.005),
                              Text(
                                '${currencyFormat.format(repo.debt)} left',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: context.screenHeight * 0.015),
                              LinearProgressIndicator(
                                value: debtPercent,
                                backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                                color: context.colorScheme.error,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.04),
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Emergency Fund',
                                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.health_and_safety_rounded, color: context.colorScheme.secondary, size: AppSizes.icon16),
                                ],
                              ),
                              SizedBox(height: context.screenHeight * 0.005),
                              Text(
                                '${currencyFormat.format(repo.emergencyFund)} saved',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: context.screenHeight * 0.015),
                              LinearProgressIndicator(
                                value: emergencyPercent,
                                backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                                color: context.colorScheme.secondary,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Income vs Expense Chart Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income vs Parkinson Budget',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text(
                          'Parkinson\'s budget boundary (limit expenses to 60% of income)',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.025),
                        // Side by Side Visual Comparison Bars
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Income',
                                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  Container(
                                    width: context.screenWidth * 0.25,
                                    height: context.screenHeight * 0.015,
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(AppSizes.br4),
                                    ),
                                  ),
                                  SizedBox(height: context.screenHeight * 0.005),
                                  Text(
                                    currencyFormat.format(repo.currentSalary),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: context.screenHeight * 0.05, color: context.colorScheme.outlineVariant),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Expenses',
                                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  Container(
                                    width: context.screenWidth * 0.15,
                                    height: context.screenHeight * 0.015,
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.error,
                                      borderRadius: BorderRadius.circular(AppSizes.br4),
                                    ),
                                  ),
                                  SizedBox(height: context.screenHeight * 0.005),
                                  Text(
                                    currencyFormat.format(3200),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Monthly Expense Breakdown
                  Text(
                    'Monthly Budget Allocation',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  AppCard(
                    child: Column(
                      children: repo.expenses.map((expense) {
                        final ratio = expense.amount / 3200.0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: context.screenHeight * 0.015),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    expense.category,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${currencyFormat.format(expense.amount)} (${(ratio * 100).toStringAsFixed(0)}%)',
                                    style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.screenHeight * 0.006),
                              LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                                color: context.colorScheme.primary,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          ),
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
}
