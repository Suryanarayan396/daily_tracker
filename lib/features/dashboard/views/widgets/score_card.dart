import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_card.dart';

class ScoreCard extends StatelessWidget {
  final int dailyScore;
  final int weeklyScore;
  final VoidCallback onScoreIncrement;

  const ScoreCard({
    super.key,
    required this.dailyScore,
    required this.weeklyScore,
    required this.onScoreIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                  color: context.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSizes.br8),
                ),
                child: Icon(
                  Icons.offline_bolt_rounded,
                  color: context.colorScheme.secondary,
                  size: AppSizes.icon24,
                ),
              ),
              FilledButton.tonal(
                onPressed: dailyScore < 100 ? onScoreIncrement : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.screenWidth * 0.03,
                    vertical: 0,
                  ),
                  minimumSize: Size(0, context.screenHeight * 0.035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.br12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: AppSizes.icon16),
                    Text(
                      '+5',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.015),
          Text(
            'Daily / Weekly Score',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.screenHeight * 0.005),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                '$dailyScore',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                ' / 100 pts',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.005),
          Text(
            'Weekly Total: $weeklyScore pts',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
