import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/life_os_repository.dart';
import '../../../core/widgets/app_card.dart';

class DailyReflectionPage extends StatefulWidget {
  const DailyReflectionPage({super.key});

  @override
  State<DailyReflectionPage> createState() => _DailyReflectionPageState();
}

class _DailyReflectionPageState extends State<DailyReflectionPage> {
  final _murphyCtrl = TextEditingController();
  final _paretoCtrl = TextEditingController();
  final _gilbertCtrl = TextEditingController();
  final _occamCtrl = TextEditingController();
  final _parkinsonCtrl = TextEditingController();
  final _hanlonCtrl = TextEditingController();
  final _peterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing reflections
    final repo = LifeOSRepository();
    _murphyCtrl.text = repo.currentReflection.murphy;
    _paretoCtrl.text = repo.currentReflection.pareto;
    _gilbertCtrl.text = repo.currentReflection.gilbert;
    _occamCtrl.text = repo.currentReflection.occam;
    _parkinsonCtrl.text = repo.currentReflection.parkinson;
    _hanlonCtrl.text = repo.currentReflection.hanlon;
    _peterCtrl.text = repo.currentReflection.peter;

    // Add listeners to calculate dynamic score
    _murphyCtrl.addListener(_updateScore);
    _paretoCtrl.addListener(_updateScore);
    _gilbertCtrl.addListener(_updateScore);
    _occamCtrl.addListener(_updateScore);
    _parkinsonCtrl.addListener(_updateScore);
    _hanlonCtrl.addListener(_updateScore);
    _peterCtrl.addListener(_updateScore);
  }

  int _calculateScore() {
    int answered = 0;
    if (_murphyCtrl.text.trim().isNotEmpty) answered++;
    if (_paretoCtrl.text.trim().isNotEmpty) answered++;
    if (_gilbertCtrl.text.trim().isNotEmpty) answered++;
    if (_occamCtrl.text.trim().isNotEmpty) answered++;
    if (_parkinsonCtrl.text.trim().isNotEmpty) answered++;
    if (_hanlonCtrl.text.trim().isNotEmpty) answered++;
    if (_peterCtrl.text.trim().isNotEmpty) answered++;
    return ((answered / 7.0) * 100).round();
  }

  void _updateScore() {
    setState(() {});
  }

  @override
  void dispose() {
    _murphyCtrl.dispose();
    _paretoCtrl.dispose();
    _gilbertCtrl.dispose();
    _occamCtrl.dispose();
    _parkinsonCtrl.dispose();
    _hanlonCtrl.dispose();
    _peterCtrl.dispose();
    super.dispose();
  }

  void _saveReflection(BuildContext context) {
    final score = _calculateScore();
    final data = ReflectionData(
      murphy: _murphyCtrl.text,
      pareto: _paretoCtrl.text,
      gilbert: _gilbertCtrl.text,
      occam: _occamCtrl.text,
      parkinson: _parkinsonCtrl.text,
      hanlon: _hanlonCtrl.text,
      peter: _peterCtrl.text,
      date: DateTime.now(),
      score: score,
    );

    LifeOSRepository().updateReflection(data);
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br8)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: context.screenWidth * 0.02),
            Text(
              'Reflection saved successfully! (+$score pts)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();
    Color scoreColor = context.colorScheme.error;
    String status = "Incomplete";
    if (score >= 80) {
      scoreColor = context.colorScheme.secondary;
      status = "Mindful State";
    } else if (score >= 40) {
      scoreColor = context.colorScheme.tertiary;
      status = "Reflecting...";
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
              Text(
                'Mental Reflection',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.005),
              Text(
                'Audit your day using core mental frameworks.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.025),

              // Score Summary Card
              AppCard(
                color: context.colorScheme.surface,
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: context.screenWidth * 0.16,
                          height: context.screenWidth * 0.16,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 6,
                            backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          '$score%',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: context.screenWidth * 0.05),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reflection Score',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.004),
                          Text(
                            'Status: $status',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: scoreColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.screenHeight * 0.03),

              // Prompt Fields
              _buildReflectionInput(
                context: context,
                title: "Murphy's Law",
                subtitle: "What could go wrong tomorrow? How will you mitigate it?",
                controller: _murphyCtrl,
                icon: Icons.security_rounded,
                iconColor: context.colorScheme.error,
              ),
              _buildReflectionInput(
                context: context,
                title: "Pareto Principle (80/20 Rule)",
                subtitle: "What single task will yield 80% of your results tomorrow?",
                controller: _paretoCtrl,
                icon: Icons.star_rounded,
                iconColor: context.colorScheme.primary,
              ),
              _buildReflectionInput(
                context: context,
                title: "Gilbert's Law",
                subtitle: "What is the real problem you are trying to solve right now?",
                controller: _gilbertCtrl,
                icon: Icons.psychology_rounded,
                iconColor: context.colorScheme.tertiary,
              ),
              _buildReflectionInput(
                context: context,
                title: "Occam's Razor",
                subtitle: "What is the simplest solution to your most complex problem?",
                controller: _occamCtrl,
                icon: Icons.cleaning_services_rounded,
                iconColor: context.colorScheme.secondary,
              ),
              _buildReflectionInput(
                context: context,
                title: "Parkinson's Law",
                subtitle: "What artificial deadline will you set to speed up execution?",
                controller: _parkinsonCtrl,
                icon: Icons.alarm_rounded,
                iconColor: context.colorScheme.tertiary,
              ),
              _buildReflectionInput(
                context: context,
                title: "Hanlon's Razor",
                subtitle: "Have you misattributed malice where ignorance/misunderstanding was at play?",
                controller: _hanlonCtrl,
                icon: Icons.favorite_rounded,
                iconColor: context.colorScheme.secondary,
              ),
              _buildReflectionInput(
                context: context,
                title: "Peter Principle",
                subtitle: "Are you practicing skills at the edge of your comfort zone today?",
                controller: _peterCtrl,
                icon: Icons.trending_up_rounded,
                iconColor: context.colorScheme.primary,
              ),

              SizedBox(height: context.screenHeight * 0.02),

              // Save Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: context.screenHeight * 0.06,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveReflection(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.br12),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text(
                      'Save Reflection',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionInput({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.02),
      child: AppCard(
        color: context.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: AppSizes.icon24),
                SizedBox(width: context.screenWidth * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.screenHeight * 0.008),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: context.screenHeight * 0.015),
            TextField(
              controller: controller,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your reflection here...',
                hintStyle: TextStyle(color: context.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                fillColor: Colors.black.withOpacity(0.2),
                filled: true,
                contentPadding: EdgeInsets.all(context.screenWidth * 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.br8),
                  borderSide: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.br8),
                  borderSide: BorderSide(color: context.colorScheme.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
