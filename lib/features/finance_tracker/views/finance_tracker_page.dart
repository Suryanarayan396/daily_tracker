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
import '../models/finance_tracker_model.dart';

class FinanceTrackerPage extends StatelessWidget {
  const FinanceTrackerPage({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home_rounded;
      case 'groceries':
        return Icons.shopping_basket_rounded;
      case 'utilities':
        return Icons.flash_on_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.local_movies_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }

  int _calculateMonthsTracked(List<ExpenseItemModel> expenses) {
    final now = DateTime.now();
    final currentMonthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final monthsSet = <String>{currentMonthStr};
    for (final exp in expenses) {
      monthsSet.add("${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}");
    }
    return monthsSet.length;
  }

  void _showEditSheet(
    BuildContext context, {
    required String title,
    required String label,
    required double initialValue,
    required IconData icon,
    required void Function(double) onSave,
  }) {
    final bloc = context.read<FinanceTrackerBloc>();
    final ctrl = TextEditingController(text: initialValue == 0.0 ? '' : initialValue.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Padding(
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
                Center(
                  child: Container(
                    width: ctx.screenWidth * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: ctx.screenHeight * 0.02),
                Text(title, style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: ctx.screenHeight * 0.025),
                TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: Icon(icon, color: ctx.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                  ),
                ),
                SizedBox(height: ctx.screenHeight * 0.025),
                SizedBox(
                  width: double.infinity,
                  height: ctx.screenHeight * 0.055,
                  child: ElevatedButton(
                    onPressed: () {
                      final value = double.tryParse(ctrl.text.trim()) ?? 0.0;
                      onSave(value);
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctx.colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBreakdownSheet(
    BuildContext context,
    List<ExpenseItemModel> thisMonthExpenses,
    FinanceTrackerState state,
  ) {
    final bloc = context.read<FinanceTrackerBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: ctx.screenHeight * 0.75,
                padding: EdgeInsets.symmetric(
                  horizontal: ctx.screenWidth * 0.05,
                  vertical: ctx.screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: ctx.screenWidth * 0.12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ctx.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: ctx.screenHeight * 0.02),
                    Text(
                      "This Month's Breakdown",
                      style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: ctx.screenHeight * 0.005),
                    Text(
                      "${thisMonthExpenses.length} entries recorded this month",
                      style: ctx.textTheme.bodyMedium?.copyWith(color: ctx.colorScheme.onSurfaceVariant),
                    ),
                    SizedBox(height: ctx.screenHeight * 0.02),
                    Expanded(
                      child: thisMonthExpenses.isEmpty
                          ? Center(
                              child: Text(
                                "No expenses recorded this month",
                                style: TextStyle(color: ctx.colorScheme.onSurfaceVariant),
                              ),
                            )
                          : ListView.separated(
                              itemCount: thisMonthExpenses.length,
                              separatorBuilder: (_, __) => Divider(color: ctx.colorScheme.outlineVariant.withOpacity(0.3)),
                              itemBuilder: (context, index) {
                                final expense = thisMonthExpenses[index];
                                return _buildExpenseTile(context, expense, state);
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDeleteExpenseModal(
    BuildContext context,
    ExpenseItemModel expense,
    FinanceTrackerState state,
  ) {
    final bloc = context.read<FinanceTrackerBloc>();
    final categoryCtrl = TextEditingController(text: expense.category);
    final descCtrl = TextEditingController(text: expense.description);
    final amtCtrl = TextEditingController(text: expense.amount.toStringAsFixed(0));
    DateTime selectedDate = expense.date;

    final categories = ['Rent', 'Groceries', 'Utilities', 'Transport', 'Entertainment', 'Food', 'Health', 'Education', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
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
                      Center(
                        child: Container(
                          width: ctx.screenWidth * 0.12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ctx.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: ctx.screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Edit Expense',
                            style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: ctx.colorScheme.error, size: 28),
                            onPressed: () {
                              context.read<FinanceTrackerBloc>().add(FinanceTrackerExpenseDeleted(id: expense.id));
                              HapticFeedback.heavyImpact();
                              Navigator.pop(ctx); // Close edit sheet
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: ctx.screenHeight * 0.02),

                      // Category List Selector
                      Text(
                        'Category',
                        style: ctx.textTheme.bodyMedium?.copyWith(color: ctx.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = categoryCtrl.text.toLowerCase() == cat.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      categoryCtrl.text = cat;
                                    });
                                  }
                                },
                                selectedColor: ctx.colorScheme.primary.withOpacity(0.25),
                                checkmarkColor: ctx.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? ctx.colorScheme.primary : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextField(
                        controller: descCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      TextField(
                        controller: amtCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: const Icon(Icons.payments_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Selection
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                          ),
                          child: Text(
                            DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: ctx.screenHeight * 0.03),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: ctx.screenHeight * 0.055,
                        child: ElevatedButton(
                          onPressed: () {
                            final cat = categoryCtrl.text.trim();
                            final desc = descCtrl.text.trim();
                            final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                            if (cat.isNotEmpty && amt > 0) {
                              final updated = expense.copyWith(
                                category: cat,
                                description: desc,
                                amount: amt,
                                date: selectedDate,
                              );
                              context.read<FinanceTrackerBloc>().add(
                                    FinanceTrackerExpenseUpdated(expense: updated),
                                  );
                              HapticFeedback.mediumImpact();
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ctx.colorScheme.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                          ),
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddExpenseBottomSheet(BuildContext context) {
    final bloc = context.read<FinanceTrackerBloc>();
    final categoryCtrl = TextEditingController(text: 'Food');
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final categories = ['Rent', 'Groceries', 'Utilities', 'Transport', 'Entertainment', 'Food', 'Health', 'Education', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
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
                      Center(
                        child: Container(
                          width: ctx.screenWidth * 0.12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: ctx.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: ctx.screenHeight * 0.02),
                      Text(
                        'Add Expense',
                        style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: ctx.screenHeight * 0.02),

                      // Category List Selector
                      Text(
                        'Category',
                        style: ctx.textTheme.bodyMedium?.copyWith(color: ctx.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = categoryCtrl.text.toLowerCase() == cat.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      categoryCtrl.text = cat;
                                    });
                                  }
                                },
                                selectedColor: ctx.colorScheme.primary.withOpacity(0.25),
                                checkmarkColor: ctx.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? ctx.colorScheme.primary : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextField(
                        controller: descCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      TextField(
                        controller: amtCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: const Icon(Icons.payments_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Selection
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                          ),
                          child: Text(
                            DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: ctx.screenHeight * 0.03),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: ctx.screenHeight * 0.055,
                        child: ElevatedButton(
                          onPressed: () {
                            final cat = categoryCtrl.text.trim();
                            final desc = descCtrl.text.trim();
                            final amt = double.tryParse(amtCtrl.text.trim()) ?? 0.0;
                            if (cat.isNotEmpty && amt > 0) {
                              context.read<FinanceTrackerBloc>().add(
                                    FinanceTrackerExpenseAdded(
                                      category: cat,
                                      description: desc,
                                      amount: amt,
                                      date: selectedDate,
                                    ),
                                  );
                              HapticFeedback.mediumImpact();
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ctx.colorScheme.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                          ),
                          child: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildExpenseTile(BuildContext context, ExpenseItemModel expense, FinanceTrackerState state) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final timeFormat = DateFormat('h:mm a');
    final dayFormat = DateFormat('d MMM');

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showEditDeleteExpenseModal(context, expense, state);
      },
      borderRadius: BorderRadius.circular(AppSizes.br12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: context.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                  if (expense.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      expense.description,
                      style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmt.format(expense.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  "${dayFormat.format(expense.date)}, ${timeFormat.format(expense.date)}",
                  style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.br16),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: context.screenHeight * 0.016,
            horizontal: context.screenWidth * 0.03,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.br16),
            border: Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: context.colorScheme.primary, size: 24),
              SizedBox(height: context.screenHeight * 0.008),
              Text(
                label,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.screenHeight * 0.006),
              Text(
                value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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

        // --- Reactive Net Worth Calculation ---
        final monthsTracked = _calculateMonthsTracked(state.expenses);
        final totalExpenses = state.totalExpenses;
        final netWorth = (settings.salary * monthsTracked) - totalExpenses + settings.savings + settings.emergencyFund;

        // --- Monthly Summary Calculation ---
        final now = DateTime.now();
        final thisMonthExpenses = state.expenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
        final thisMonthSum = thisMonthExpenses.fold(0.0, (sum, item) => sum + item.amount);
        final balanceInHand = settings.salary - thisMonthSum;

        // --- Today's Expenses ---
        final todayExpenses = state.expenses
            .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
            .toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddExpenseBottomSheet(context);
            },
            backgroundColor: context.colorScheme.primary,
            foregroundColor: Colors.black,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenWidth * 0.05,
                vertical: context.screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
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
                            "Shield your assets against Murphy's Law.",
                            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // 1. --- Net Worth Tile (Top Card) ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.screenWidth * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colorScheme.primary.withOpacity(0.15), context.colorScheme.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.br16),
                      border: Border.all(color: context.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'NET WORTH',
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
                          fmt.format(netWorth),
                          style: context.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text(
                          '($monthsTracked months tracked)',
                          style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.02),

                  // 2. --- Financial Overview Tiles (Row of 3) ---
                  Row(
                    children: [
                      _buildOverviewTile(
                        context,
                        label: 'Salary',
                        value: fmt.format(settings.salary),
                        icon: Icons.payments_rounded,
                        onTap: () => _showEditSheet(
                          context,
                          title: 'Update Monthly Salary',
                          label: 'Monthly Salary (₹)',
                          initialValue: settings.salary,
                          icon: Icons.payments_rounded,
                          onSave: (val) {
                            context.read<FinanceTrackerBloc>().add(
                                  FinanceTrackerSettingsUpdated(salary: val),
                                );
                          },
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.025),
                      _buildOverviewTile(
                        context,
                        label: 'Savings',
                        value: fmt.format(settings.savings),
                        icon: Icons.savings_rounded,
                        onTap: () => _showEditSheet(
                          context,
                          title: 'Update Current Savings',
                          label: 'Current Savings (₹)',
                          initialValue: settings.savings,
                          icon: Icons.savings_rounded,
                          onSave: (val) {
                            context.read<FinanceTrackerBloc>().add(
                                  FinanceTrackerSettingsUpdated(savings: val),
                                );
                          },
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.025),
                      _buildOverviewTile(
                        context,
                        label: 'Emergency Fund',
                        value: fmt.format(settings.emergencyFund),
                        icon: Icons.health_and_safety_rounded,
                        onTap: () => _showEditSheet(
                          context,
                          title: 'Update Emergency Fund',
                          label: 'Emergency Fund (₹)',
                          initialValue: settings.emergencyFund,
                          icon: Icons.health_and_safety_rounded,
                          onSave: (val) {
                            context.read<FinanceTrackerBloc>().add(
                                  FinanceTrackerSettingsUpdated(emergencyFund: val),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.02),

                  // 3. --- Monthly Summary Tile ---
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showBreakdownSheet(context, thisMonthExpenses, state);
                    },
                    borderRadius: BorderRadius.circular(AppSizes.br16),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppSizes.br16),
                        border: Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Monthly Summary",
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: context.colorScheme.onSurfaceVariant, size: 14),
                            ],
                          ),
                          SizedBox(height: context.screenHeight * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "This Month's Expenses",
                                    style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fmt.format(thisMonthSum),
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Balance in Hand",
                                    style: context.textTheme.labelMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fmt.format(balanceInHand),
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: balanceInHand >= 0 ? context.colorScheme.primary : context.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // 4. --- Daily Expense Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMM').format(DateTime.now()),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Today\'s Expenses',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  AppCard(
                    child: todayExpenses.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.02),
                            child: Center(
                              child: Text(
                                "No expenses recorded today",
                                style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          )
                        : Column(
                            children: List.generate(todayExpenses.length, (index) {
                              final expense = todayExpenses[index];
                              return Column(
                                children: [
                                  _buildExpenseTile(context, expense, state),
                                  if (index < todayExpenses.length - 1)
                                    Divider(color: context.colorScheme.outlineVariant.withOpacity(0.3)),
                                ],
                              );
                            }),
                          ),
                  ),
                  SizedBox(height: context.screenHeight * 0.06),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
