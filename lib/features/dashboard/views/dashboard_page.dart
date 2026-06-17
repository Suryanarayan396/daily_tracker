import 'dart:async';
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

  void _showEditTargetSalaryDialog(BuildContext context, double currentTarget) {
    final ctrl = TextEditingController(text: currentTarget.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ctx.colorScheme.surface,
          title: const Text('Update Target Salary', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Target Salary (₹/mo)',
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
                final target = double.tryParse(ctrl.text.trim()) ?? 0.0;
                context.read<DashboardBloc>().add(DashboardTargetSalaryUpdated(target));
                HapticFeedback.mediumImpact();
                Navigator.pop(ctx);
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
                  
                  // ── Top Header: Clock time & Username ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trillionaire Life Dashboard',
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            loaded.username,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const _ClockWidget(),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // ── Career Tracker Section ─────────────────────────────────
                  _buildSectionHeader(context, '💼 Career Tracker'),
                  SizedBox(height: context.screenHeight * 0.015),
                  
                  // 1. Current Salary & Target Salary Tile
                  GestureDetector(
                    onTap: () => _showEditTargetSalaryDialog(context, loaded.targetSalary),
                    child: Container(
                      padding: EdgeInsets.all(context.screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary.withOpacity(0.12),
                            context.colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.br12),
                        border: Border.all(color: context.colorScheme.primary.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT SALARY',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                currencyFormat.format(loaded.currentSalary),
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: context.colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'TARGET SALARY',
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.edit_rounded, size: 12, color: context.colorScheme.primary),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                currencyFormat.format(loaded.targetSalary),
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.015),

                  // 2. Sent Applications Count Tile
                  AppCard(
                    padding: EdgeInsets.all(context.screenWidth * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Applications Sent',
                          style: context.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${loaded.totalApplications}',
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 3. Upcoming Interview Details
                  if (loaded.upcomingInterview != null) ...[
                    SizedBox(height: context.screenHeight * 0.015),
                    Container(
                      padding: EdgeInsets.all(context.screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B).withOpacity(0.12),
                            context.colorScheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.br12),
                        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.event_note_rounded, color: Color(0xFFF59E0B), size: 20),
                          ),
                          SizedBox(width: context.screenWidth * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UPCOMING INTERVIEW',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${loaded.upcomingInterview!['company']} • ${loaded.upcomingInterview!['role']}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  loaded.upcomingInterview!['interviewDate'],
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: context.screenHeight * 0.015),

                  // 4. Counts according to each status
                  AppCard(
                    padding: EdgeInsets.all(context.screenWidth * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pipeline Distribution',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusMiniTile(context, 'Recruit', loaded.statusCounts['Recruiter'] ?? 0, const Color(0xFFF59E0B)),
                            _buildStatusMiniTile(context, 'Sched', loaded.statusCounts['Interview Scheduled'] ?? 0, context.colorScheme.tertiary),
                            _buildStatusMiniTile(context, 'Done', loaded.statusCounts['Interview Done'] ?? 0, context.colorScheme.primary),
                            _buildStatusMiniTile(context, 'Offer', loaded.statusCounts['Offer'] ?? 0, context.colorScheme.secondary),
                            _buildStatusMiniTile(context, 'Reject', loaded.statusCounts['Rejected'] ?? 0, context.colorScheme.error),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.035),

                  // ── Finance Tracker Section ────────────────────────────────
                  _buildSectionHeader(context, '💰 Finance Tracker'),
                  SizedBox(height: context.screenHeight * 0.015),
                  
                  // Row of 3 Balance, Emergency, Savings
                  Row(
                    children: [
                      Expanded(
                        child: _buildFinanceCard(
                          context,
                          'Balance',
                          currencyFormat.format(loaded.balance),
                          Icons.account_balance_wallet_rounded,
                          context.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.03),
                      Expanded(
                        child: _buildFinanceCard(
                          context,
                          'Emergency',
                          currencyFormat.format(loaded.emergencyFund),
                          Icons.health_and_safety_rounded,
                          context.colorScheme.secondary,
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.03),
                      Expanded(
                        child: _buildFinanceCard(
                          context,
                          'Savings',
                          currencyFormat.format(loaded.savings),
                          Icons.savings_rounded,
                          context.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.035),

                  // ── YouTube Tracker Section ────────────────────────────────
                  _buildSectionHeader(context, '🎥 YouTube Tracker'),
                  SizedBox(height: context.screenHeight * 0.015),

                  // 1. Content and Published Stats
                  AppCard(
                    padding: EdgeInsets.all(context.screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Content Velocity',
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${loaded.youtubePublishedContent} / ${loaded.youtubeTotalContent} Published',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFFF0000),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.screenHeight * 0.012),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: loaded.youtubeTotalContent > 0
                                ? (loaded.youtubePublishedContent / loaded.youtubeTotalContent)
                                : 0.0,
                            backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.2),
                            color: const Color(0xFFFF0000),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. Upcoming Content to be posted
                  if (loaded.upcomingContent != null) ...[
                    SizedBox(height: context.screenHeight * 0.015),
                    Container(
                      padding: EdgeInsets.all(context.screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppSizes.br12),
                        border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0000).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.video_library_rounded, color: Color(0xFFFF0000), size: 18),
                          ),
                          SizedBox(width: context.screenWidth * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UPCOMING VIDEO RELEASE',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFFF0000),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  loaded.upcomingContent!['title'],
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 1),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 12, color: context.colorScheme.onSurfaceVariant),
                                    SizedBox(width: 4),
                                    Text(
                                      'Target: ${loaded.upcomingContent!['target_date']}',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: context.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.outlineVariant.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        loaded.upcomingContent!['status'].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: context.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: context.screenHeight * 0.05),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatusMiniTile(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: EdgeInsets.all(context.screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(height: context.screenHeight * 0.012),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1),
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockWidget extends StatefulWidget {
  const _ClockWidget();

  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(_now);
    final dateStr = DateFormat('EEE, d MMM').format(_now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeStr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          dateStr,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
