import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/life_os_repository.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/repository_observer.dart';

class CareerTrackerPage extends StatelessWidget {
  const CareerTrackerPage({super.key});

  void showAddApplicationDialog(BuildContext context) {
    final companyCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    String selectedStatus = 'Applied';
    
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
                'Add Job Application',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),
              TextField(
                controller: companyCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              TextField(
                controller: roleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Role / Position',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              TextField(
                controller: salaryCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Offered/Target Salary (Monthly \$)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                dropdownColor: context.colorScheme.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Pipeline Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Applied', child: Text('Applied')),
                  DropdownMenuItem(value: 'Screening', child: Text('Recruiter Screen')),
                  DropdownMenuItem(value: 'Technical', child: Text('Technical Round')),
                  DropdownMenuItem(value: 'Final', child: Text('Final Loop')),
                  DropdownMenuItem(value: 'Offer', child: Text('Offer Received')),
                ],
                onChanged: (val) {
                  if (val != null) selectedStatus = val;
                },
              ),
              SizedBox(height: context.screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: context.screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    final company = companyCtrl.text.trim();
                    final role = roleCtrl.text.trim();
                    final salary = double.tryParse(salaryCtrl.text.trim()) ?? 0.0;

                    if (company.isNotEmpty && role.isNotEmpty) {
                      LifeOSRepository().addJobApplication(company, role, salary, selectedStatus);
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.br12),
                    ),
                  ),
                  child: const Text('Add Application', style: TextStyle(fontWeight: FontWeight.bold)),
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
        // Compute stats
        final totalApps = repo.applications.length;
        final screening = repo.applications.where((app) => app.status == 'Screening').length;
        final technical = repo.applications.where((app) => app.status == 'Technical').length;
        final offers = repo.applications.where((app) => app.status == 'Offer').length;

        final percentSalary = (repo.currentSalary / repo.targetSalary).clamp(0.0, 1.0);
        final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

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
                            'Career Growth',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.005),
                          Text(
                            'Optimize your career pivot pipeline.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => showAddApplicationDialog(context),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(AppSizes.padding12),
                        ),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // Statistics Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: context.screenWidth * 0.04,
                    mainAxisSpacing: context.screenWidth * 0.04,
                    childAspectRatio: 1.6,
                    children: [
                      _buildStatCard(context, 'Apps Sent', '$totalApps', Icons.send_rounded, context.colorScheme.primary),
                      _buildStatCard(context, 'Screens Scheduled', '$screening', Icons.phone_callback_rounded, context.colorScheme.tertiary),
                      _buildStatCard(context, 'Technical Rounds', '$technical', Icons.code_rounded, context.colorScheme.tertiary),
                      _buildStatCard(context, 'Offers Secured', '$offers', Icons.emoji_events_rounded, context.colorScheme.secondary),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Salary Target Progress
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Salary Target Pivot',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${(percentSalary * 100).toStringAsFixed(0)}%',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text(
                          'Current: ${currencyFormat.format(repo.currentSalary)}/mo  •  Target: ${currencyFormat.format(repo.targetSalary)}/mo',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.015),
                        LinearProgressIndicator(
                          value: percentSalary,
                          backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                          color: context.colorScheme.secondary,
                          minHeight: context.screenHeight * 0.008,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Pipeline Timeline
                  Text(
                    'Active Interview Pipeline',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (repo.applications.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.02),
                          child: Text(
                            'No applications recorded. Tap + to add.',
                            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: repo.applications.length,
                      itemBuilder: (context, index) {
                        final app = repo.applications[index];
                        return _buildPipelineItem(context, app);
                      },
                    ),

                  SizedBox(height: context.screenHeight * 0.03),

                  // Weekly Application Chart
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Submissions',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text(
                          'Total this week: ${repo.applications.where((app) => app.dateApplied.difference(DateTime.now()).inDays.abs() <= 7).length} applications',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.025),
                        // Custom Drawn Weekly Chart
                        _buildWeeklyChart(context),
                      ],
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

  Widget _buildStatCard(BuildContext context, String title, String val, IconData icon, Color color) {
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
          SizedBox(height: context.screenHeight * 0.008),
          Text(
            val,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem(BuildContext context, JobApplication app) {
    Color statusColor;
    switch (app.status) {
      case 'Offer':
        statusColor = context.colorScheme.secondary;
        break;
      case 'Technical':
      case 'Final':
        statusColor = context.colorScheme.primary;
        break;
      case 'Screening':
        statusColor = context.colorScheme.tertiary;
        break;
      default:
        statusColor = context.colorScheme.onSurfaceVariant;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.015),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: context.screenHeight * 0.06,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: context.screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.company,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    app.role,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.screenWidth * 0.025,
                    vertical: context.screenHeight * 0.004,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.br12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    app.status,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.005),
                if (app.salary > 0)
                  Text(
                    '\$${app.salary.toStringAsFixed(0)}/mo',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    // We will hardcode simulated bar values for days (Mon: 3, Tue: 2, Wed: 5, Thu: 4, Fri: 1, Sat: 0, Sun: 2)
    final barValues = [3, 2, 5, 4, 1, 0, 2];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const maxVal = 5;

    return SizedBox(
      height: context.screenHeight * 0.16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (idx) {
          final val = barValues[idx];
          // Proportional height
          final double ratio = maxVal > 0 ? (val / maxVal) : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$val',
                style: context.textTheme.bodySmall?.copyWith(
                  color: val > 0 ? context.colorScheme.primary : Colors.transparent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.004),
              Container(
                width: context.screenWidth * 0.06,
                height: (context.screenHeight * 0.1) * ratio.clamp(0.05, 1.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colorScheme.primary,
                      context.colorScheme.primary.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.008),
              Text(
                days[idx],
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
