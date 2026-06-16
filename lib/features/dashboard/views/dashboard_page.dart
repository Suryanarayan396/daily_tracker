import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_card.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _showEditHitDialog(BuildContext context, String currentHit) {
    final hitCtrl = TextEditingController(text: currentHit);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ctx.colorScheme.surface,
          title: const Text('Update Highest Impact Task', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: hitCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'HIT (Pareto Principle)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: ctx.colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                final task = hitCtrl.text.trim();
                if (task.isNotEmpty) {
                  context.read<DashboardBloc>().add(DashboardHitUpdated(task));
                  HapticFeedback.mediumImpact();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.data == null) {
            if (state.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: context.colorScheme.error,
                        size: AppSizes.icon48,
                      ),
                      SizedBox(height: context.screenHeight * 0.02),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.error,
                        ),
                      ),
                      SizedBox(height: context.screenHeight * 0.03),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<DashboardBloc>().add(const DashboardStarted());
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const AppLoader();
          }
          final loaded = state.data!;
            final salaryPercent = loaded.targetSalary > 0
                ? (loaded.currentSalary / loaded.targetSalary).clamp(0.0, 1.0)
                : 0.0;
            final careerPercent = (loaded.careerApplicationsCount / 5.0).clamp(0.0, 1.0);
            final youtubePercent = (loaded.youtubeVideosUploadedCount / 4.0).clamp(0.0, 1.0);

            Color scoreColor = context.colorScheme.error;
            String scoreStatus = "Action Needed";
            if (loaded.dailyScore >= 80) {
              scoreColor = context.colorScheme.secondary;
              scoreStatus = "Optimal Growth";
            } else if (loaded.dailyScore >= 50) {
              scoreColor = context.colorScheme.tertiary;
              scoreStatus = "Moderate Progress";
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * 0.05,
                  vertical: context.screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.screenHeight * 0.01),
                    // Top welcome row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LifeOS Dashboard',
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              loaded.welcomeMessage,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        // Daily Streak Indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.screenWidth * 0.03,
                            vertical: context.screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppSizes.br24),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: AppSizes.icon20),
                              SizedBox(width: context.screenWidth * 0.01),
                              Text(
                                '${loaded.streakDays}d Streak',
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.screenHeight * 0.02),

                    // Daily Mission banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppSizes.br12),
                        border: Border.all(
                          color: context.colorScheme.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars_rounded, color: context.colorScheme.primary, size: AppSizes.icon24),
                          SizedBox(width: context.screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DAILY MISSION',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  loaded.dailyMission,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.03),

                    // Score & Streak Row
                    Row(
                      children: [
                        // Daily Score Card (Dynamic circle progress)
                        Expanded(
                          flex: 11,
                          child: AppCard(
                            height: context.screenHeight * 0.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: context.screenWidth * 0.22,
                                      height: context.screenWidth * 0.22,
                                      child: CircularProgressIndicator(
                                        value: loaded.dailyScore / 100,
                                        strokeWidth: 8,
                                        backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                                        color: scoreColor,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${loaded.dailyScore}',
                                          style: context.textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'pts',
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: context.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.screenHeight * 0.015),
                                Text(
                                  scoreStatus,
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: context.screenWidth * 0.04),
                        // Highest Impact Task Card (Pareto HIT)
                        Expanded(
                          flex: 12,
                          child: AppCard(
                            height: context.screenHeight * 0.2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'PARETO H.I.T.',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: context.colorScheme.tertiary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _showEditHitDialog(context, loaded.highestImpactTask),
                                      icon: Icon(Icons.edit_rounded, color: context.colorScheme.onSurfaceVariant, size: AppSizes.icon16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                Text(
                                  loaded.highestImpactTask,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: loaded.isHitCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      loaded.isHitCompleted ? 'Completed' : 'Pending',
                                      style: TextStyle(
                                        color: loaded.isHitCompleted
                                            ? context.colorScheme.secondary
                                            : context.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.85,
                                      child: Switch(
                                        value: loaded.isHitCompleted,
                                        activeColor: context.colorScheme.secondary,
                                        onChanged: (val) {
                                          context.read<DashboardBloc>().add(const DashboardHitToggled());
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.screenHeight * 0.03),

                    // Financial KPIs Section (Grid of 4 cards)
                    Text(
                      'Financial Health KPI',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.015),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: context.screenWidth * 0.04,
                      mainAxisSpacing: context.screenWidth * 0.04,
                      childAspectRatio: 1.6,
                      children: [
                        _buildKpiCard(context, 'Current Salary', currencyFormat.format(loaded.currentSalary), Icons.account_balance_wallet_rounded, context.colorScheme.primary),
                        _buildKpiCard(context, 'Target Salary', currencyFormat.format(loaded.targetSalary), Icons.track_changes_rounded, context.colorScheme.secondary),
                        _buildKpiCard(context, 'Liabilities / Debt', currencyFormat.format(loaded.debt), Icons.payment_rounded, context.colorScheme.error),
                        _buildKpiCard(context, 'Emergency Fund', currencyFormat.format(loaded.emergencyFund), Icons.health_and_safety_rounded, context.colorScheme.secondary),
                      ],
                    ),
                    SizedBox(height: context.screenHeight * 0.03),

                    // Progress Vectors Section
                    Text(
                      'Active Vectors Progress',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.015),
                    AppCard(
                      child: Column(
                        children: [
                          _buildVectorProgress(context, 'Salary Pivot Goal', salaryPercent, context.colorScheme.secondary),
                          SizedBox(height: context.screenHeight * 0.02),
                          _buildVectorProgress(context, 'Career Submissions', careerPercent, context.colorScheme.primary),
                          SizedBox(height: context.screenHeight * 0.02),
                          _buildVectorProgress(context, 'YouTube Content Velocity', youtubePercent, const Color(0xFFFF0000)),
                        ],
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.03),

                    // Motivational Insight Card
                    AppCard(
                      color: context.colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outline_rounded, color: context.colorScheme.tertiary, size: AppSizes.icon20),
                                  SizedBox(width: context.screenWidth * 0.02),
                                  Text(
                                    'SYSTEMIC LAW INSIGHT',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: context.colorScheme.tertiary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<DashboardBloc>().add(const DashboardInsightRotated());
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icon(Icons.refresh_rounded, color: context.colorScheme.onSurfaceVariant, size: AppSizes.icon20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          SizedBox(height: context.screenHeight * 0.015),
                          Text(
                            loaded.currentLawInsight,
                            style: context.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.05),
                  ],
                ),
              ),
            );
        },
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String val, IconData icon, Color color) {
    return AppCard(
      padding: EdgeInsets.all(context.screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: AppSizes.icon16),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.005),
          Text(
            val,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorProgress(BuildContext context, String label, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: context.screenHeight * 0.006),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
          color: color,
          minHeight: 5,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
