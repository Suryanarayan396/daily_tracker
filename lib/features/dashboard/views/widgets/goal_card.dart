import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_card.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final ValueChanged<double> onProgressChanged;

  const GoalCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (current / target).clamp(0.0, 1.0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.padding8),
                decoration: BoxDecoration(
                  color: context.colorScheme.tertiaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSizes.br8),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: context.colorScheme.tertiary,
                  size: AppSizes.icon24,
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.015),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.screenHeight * 0.005),
          Text(
            '${current.toStringAsFixed(0)} of ${target.toStringAsFixed(0)} completed',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            color: context.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(AppSizes.br4),
            minHeight: context.screenHeight * 0.008,
          ),
          SizedBox(height: context.screenHeight * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: current > 0 ? () => onProgressChanged(current - 1) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: context.colorScheme.onSurfaceVariant,
                iconSize: AppSizes.icon20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: current < target ? () => onProgressChanged(current + 1) : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: context.colorScheme.tertiary,
                iconSize: AppSizes.icon20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
