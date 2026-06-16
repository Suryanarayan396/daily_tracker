import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/life_os_repository.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/repository_observer.dart';

class LearningTrackerPage extends StatelessWidget {
  const LearningTrackerPage({super.key});

  void showLogSessionDialog(BuildContext context, LifeOSRepository repo) {
    final hoursCtrl = TextEditingController();
    String selectedSkill = repo.skills.first.name;

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
                'Log Learning Session',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),
              TextField(
                controller: hoursCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Hours Spent',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 1.5',
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              DropdownButtonFormField<String>(
                value: selectedSkill,
                dropdownColor: context.colorScheme.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Target Skill',
                  border: OutlineInputBorder(),
                ),
                items: repo.skills.map((sk) {
                  return DropdownMenuItem(value: sk.name, child: Text(sk.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedSkill = val;
                },
              ),
              SizedBox(height: context.screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: context.screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    final hours = double.tryParse(hoursCtrl.text.trim()) ?? 0.0;
                    if (hours > 0) {
                      repo.addLearningSession(hours, selectedSkill);
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
                  child: const Text('Log Session', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMilestoneDialog(BuildContext context, LifeOSRepository repo) {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.surface,
          title: const Text('Add Learning Milestone', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: titleCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Milestone Title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isNotEmpty) {
                  repo.addMilestone(title);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditFocusDialog(BuildContext context, LifeOSRepository repo) {
    final focusCtrl = TextEditingController(text: repo.currentLearningFocus);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colorScheme.surface,
          title: const Text('Edit Learning Focus', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: focusCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Focus Area',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                final focus = focusCtrl.text.trim();
                if (focus.isNotEmpty) {
                  repo.changeLearningFocus(focus);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryObserver(
      builder: (context, repo) {
        // Calculate weekly total hours
        final double totalWeeklyHours = repo.weeklyLearningHours.fold(0.0, (sum, val) => sum + val);

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
                            'Learning Deck',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.005),
                          Text(
                            'Escape the Peter Principle by building skills.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => showLogSessionDialog(context, repo),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(AppSizes.padding12),
                        ),
                        icon: const Icon(Icons.timer_outlined),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // Focus Area Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CURRENT LEARNING FOCUS',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showEditFocusDialog(context, repo),
                              icon: Icon(Icons.edit_rounded, color: context.colorScheme.onSurfaceVariant, size: AppSizes.icon16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        SizedBox(height: context.screenHeight * 0.01),
                        Text(
                          repo.currentLearningFocus,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Streak & Total Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSizes.padding8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: AppSizes.icon24),
                              ),
                              SizedBox(width: context.screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${repo.learningStreak} Days',
                                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Learning Streak',
                                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: context.screenWidth * 0.04),
                      Expanded(
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSizes.padding8),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.secondary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.menu_book_rounded, color: context.colorScheme.secondary, size: AppSizes.icon24),
                              ),
                              SizedBox(width: context.screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${totalWeeklyHours.toStringAsFixed(1)} hrs',
                                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Logged this week',
                                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Skill Progress Matrix
                  Text(
                    'Skill Vector Matrix',
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
                    childAspectRatio: 1.45,
                    children: repo.skills.map((skill) {
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              skill.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Level: ${(skill.progress * 100).toStringAsFixed(0)}%',
                                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                                    ),
                                    if (skill.progress >= 0.8)
                                      Icon(Icons.bolt, color: context.colorScheme.secondary, size: AppSizes.icon16),
                                  ],
                                ),
                                SizedBox(height: context.screenHeight * 0.006),
                                LinearProgressIndicator(
                                  value: skill.progress,
                                  backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                                  color: skill.progress >= 0.75
                                      ? context.colorScheme.secondary
                                      : context.colorScheme.primary,
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Weekly Learning Chart
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Study Volume',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.screenHeight * 0.025),
                        _buildWeeklyLearningChart(context, repo),
                      ],
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // Milestones Checklist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Peter Principle Milestones',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddMilestoneDialog(context, repo),
                        icon: Icon(Icons.add_circle_outline_rounded, color: context.colorScheme.secondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  AppCard(
                    child: Column(
                      children: List.generate(repo.milestones.length, (idx) {
                        final ms = repo.milestones[idx];
                        return CheckboxListTile(
                          value: ms.isCompleted,
                          title: Text(
                            ms.title,
                            style: TextStyle(
                              color: ms.isCompleted ? context.colorScheme.onSurfaceVariant : Colors.white,
                              decoration: ms.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          activeColor: context.colorScheme.secondary,
                          checkColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (_) {
                            repo.toggleMilestone(idx);
                          },
                        );
                      }),
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

  Widget _buildWeeklyLearningChart(BuildContext context, LifeOSRepository repo) {
    final barValues = repo.weeklyLearningHours;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final double maxVal = barValues.reduce((currMax, val) => val > currMax ? val : currMax);

    return SizedBox(
      height: context.screenHeight * 0.16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (idx) {
          final val = barValues[idx];
          final double ratio = maxVal > 0 ? (val / maxVal) : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                val > 0 ? '${val.toStringAsFixed(1)}h' : '',
                style: context.textTheme.bodySmall?.copyWith(
                  color: val > 0 ? context.colorScheme.secondary : Colors.transparent,
                  fontSize: 10,
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
                      context.colorScheme.secondary,
                      context.colorScheme.secondary.withOpacity(0.5),
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
