import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_card.dart';

class SalaryCard extends StatelessWidget {
  final double salary;
  final ValueChanged<double> onSalaryChanged;

  const SalaryCard({
    super.key,
    required this.salary,
    required this.onSalaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();

    return AppCard(
      onTap: () => _showEditDialog(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.padding8),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSizes.br8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: context.colorScheme.primary,
                  size: AppSizes.icon24,
                ),
              ),
              Icon(
                Icons.edit_rounded,
                color: context.colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: AppSizes.icon16,
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.015),
          Text(
            'Monthly Salary',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.screenHeight * 0.005),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyFormat.format(salary),
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: salary.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Monthly Salary'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              labelText: 'Salary Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  onSalaryChanged(newValue);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
