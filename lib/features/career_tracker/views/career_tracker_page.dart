import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../models/career_tracker_model.dart';
import '../bloc/career_tracker_bloc.dart';
import '../bloc/career_tracker_event.dart';
import '../bloc/career_tracker_state.dart';

class CareerTrackerPage extends StatelessWidget {
  const CareerTrackerPage({super.key});

  // ── Add Application Sheet ─────────────────────────────────────────────────
  void showAddApplicationDialog(BuildContext context) {
    final companyCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool recruiterContacted = false;
    String selectedStatus = 'Applied';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
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
                Center(child: Container(
                  width: ctx.screenWidth * 0.12, height: 4,
                  decoration: BoxDecoration(
                    color: ctx.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                SizedBox(height: ctx.screenHeight * 0.02),
                Text('Add Application',
                    style: ctx.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: ctx.screenHeight * 0.025),
                _inputField(ctx, companyCtrl, 'Company Name', Icons.business_rounded),
                SizedBox(height: ctx.screenHeight * 0.016),
                _inputField(ctx, roleCtrl, 'Role / Position', Icons.work_outline_rounded),
                SizedBox(height: ctx.screenHeight * 0.016),
                _inputField(ctx, salaryCtrl, 'Target Salary (₹/mo)',
                    Icons.payments_rounded, inputType: TextInputType.number),
                SizedBox(height: ctx.screenHeight * 0.016),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: ctx.colorScheme.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Pipeline Stage', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Applied', child: Text('Applied')),
                    DropdownMenuItem(value: 'Recruiter', child: Text('Recruiter Contacted')),
                    DropdownMenuItem(value: 'Interview Scheduled', child: Text('Interview Scheduled')),
                    DropdownMenuItem(value: 'Interview Done', child: Text('Interview Done')),
                    DropdownMenuItem(value: 'Offer', child: Text('Offer Received')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  ],
                  onChanged: (v) { if (v != null) setS(() => selectedStatus = v); },
                ),
                SizedBox(height: ctx.screenHeight * 0.012),
                Row(children: [
                  Checkbox(
                    value: recruiterContacted,
                    activeColor: ctx.colorScheme.primary,
                    onChanged: (v) => setS(() => recruiterContacted = v ?? false),
                  ),
                  const Text('Recruiter contacted', style: TextStyle(color: Colors.white)),
                ]),
                SizedBox(height: ctx.screenHeight * 0.012),
                _inputField(ctx, notesCtrl, 'Notes (optional)', Icons.notes_rounded, maxLines: 2),
                SizedBox(height: ctx.screenHeight * 0.025),
                SizedBox(
                  width: double.infinity,
                  height: ctx.screenHeight * 0.055,
                  child: ElevatedButton(
                    onPressed: () {
                      final company = companyCtrl.text.trim();
                      final role = roleCtrl.text.trim();
                      if (company.isEmpty || role.isEmpty) return;
                      context.read<CareerTrackerBloc>().add(CareerTrackerApplicationAdded(
                        company: company,
                        role: role,
                        status: selectedStatus,
                        salary: double.tryParse(salaryCtrl.text.trim()) ?? 0.0,
                        recruiterContacted: recruiterContacted,
                        notes: notesCtrl.text.trim(),
                      ));
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctx.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.br12)),
                    ),
                    child: const Text('Add Application',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Application Sheet ────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, CareerTrackerModel app) {
    final companyCtrl = TextEditingController(text: app.company);
    final roleCtrl = TextEditingController(text: app.role);
    final salaryCtrl = TextEditingController(text: app.salary.toStringAsFixed(0));
    final notesCtrl = TextEditingController(text: app.notes);
    bool recruiterContacted = app.recruiterContacted;
    String selectedStatus = app.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
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
                Center(child: Container(
                  width: ctx.screenWidth * 0.12, height: 4,
                  decoration: BoxDecoration(
                    color: ctx.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                SizedBox(height: ctx.screenHeight * 0.02),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Edit Application',
                      style: ctx.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<CareerTrackerBloc>().add(CareerTrackerApplicationDeleted(id: app.id));
                      HapticFeedback.mediumImpact();
                    },
                    icon: Icon(Icons.delete_outline_rounded,
                        color: ctx.colorScheme.error),
                  ),
                ]),
                SizedBox(height: ctx.screenHeight * 0.02),
                _inputField(ctx, companyCtrl, 'Company Name', Icons.business_rounded),
                SizedBox(height: ctx.screenHeight * 0.016),
                _inputField(ctx, roleCtrl, 'Role / Position', Icons.work_outline_rounded),
                SizedBox(height: ctx.screenHeight * 0.016),
                _inputField(ctx, salaryCtrl, 'Target Salary (₹/mo)',
                    Icons.payments_rounded, inputType: TextInputType.number),
                SizedBox(height: ctx.screenHeight * 0.016),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: ctx.colorScheme.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Pipeline Stage', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Applied', child: Text('Applied')),
                    DropdownMenuItem(value: 'Recruiter', child: Text('Recruiter Contacted')),
                    DropdownMenuItem(value: 'Interview Scheduled', child: Text('Interview Scheduled')),
                    DropdownMenuItem(value: 'Interview Done', child: Text('Interview Done')),
                    DropdownMenuItem(value: 'Offer', child: Text('Offer Received')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  ],
                  onChanged: (v) { if (v != null) setS(() => selectedStatus = v); },
                ),
                SizedBox(height: ctx.screenHeight * 0.012),
                Row(children: [
                  Checkbox(
                    value: recruiterContacted,
                    activeColor: ctx.colorScheme.primary,
                    onChanged: (v) => setS(() => recruiterContacted = v ?? false),
                  ),
                  const Text('Recruiter contacted', style: TextStyle(color: Colors.white)),
                ]),
                SizedBox(height: ctx.screenHeight * 0.012),
                _inputField(ctx, notesCtrl, 'Notes', Icons.notes_rounded, maxLines: 2),
                SizedBox(height: ctx.screenHeight * 0.025),
                SizedBox(
                  width: double.infinity,
                  height: ctx.screenHeight * 0.055,
                  child: ElevatedButton(
                    onPressed: () {
                      final company = companyCtrl.text.trim();
                      final role = roleCtrl.text.trim();
                      if (company.isEmpty || role.isEmpty) return;
                      
                      final updated = app.copyWith(
                        company: company,
                        role: role,
                        status: selectedStatus,
                        salary: double.tryParse(salaryCtrl.text.trim()) ?? app.salary,
                        recruiterContacted: recruiterContacted,
                        notes: notesCtrl.text.trim(),
                      );

                      context.read<CareerTrackerBloc>().add(CareerTrackerApplicationUpdated(model: updated));
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctx.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.br12)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Salary Edit Dialog ────────────────────────────────────────────────────
  void _showSalaryDialog(BuildContext context, CareerTrackerState state) {
    final currCtrl = TextEditingController(text: state.currentSalary.toStringAsFixed(0));
    final tgtCtrl = TextEditingController(text: state.targetSalary.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Salary Targets', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _inputField(ctx, currCtrl, 'Current Salary (₹)', Icons.payments_rounded,
              inputType: TextInputType.number),
          SizedBox(height: 12),
          _inputField(ctx, tgtCtrl, 'Target Salary (₹)', Icons.track_changes_rounded,
              inputType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CareerTrackerBloc>().add(CareerTrackerSalaryTargetsUpdated(
                currentSalary: double.tryParse(currCtrl.text) ?? state.currentSalary,
                targetSalary: double.tryParse(tgtCtrl.text) ?? state.targetSalary,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CareerTrackerBloc, CareerTrackerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AppLoader();
        }
        if (state.errorMessage != null && state.applications.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.screenWidth * 0.08),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.error_outline_rounded,
                    color: context.colorScheme.error, size: AppSizes.icon48),
                SizedBox(height: context.screenHeight * 0.02),
                Text(state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colorScheme.error)),
              ]),
            ),
          );
        }

        final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

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
                  // ── Header ──────────────────────────────────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Career Growth',
                          style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: context.screenHeight * 0.005),
                      Text('Track your pivot pipeline.',
                          style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant)),
                    ]),
                    FilledButton.icon(
                      onPressed: () => showAddApplicationDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.screenWidth * 0.04,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.br12)),
                      ),
                    ),
                  ]),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── 6 KPI Cards ──────────────────────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: context.screenWidth * 0.03,
                    mainAxisSpacing: context.screenWidth * 0.03,
                    childAspectRatio: 1.0,
                    children: [
                      _kpiCard(context, 'Apps\nSent', '${state.totalApps}',
                          Icons.send_rounded, context.colorScheme.primary),
                      _kpiCard(context, 'Recruiters\nContacted', '${state.recruitersContacted}',
                          Icons.person_search_rounded, context.colorScheme.tertiary),
                      _kpiCard(context, 'Interviews\nScheduled', '${state.interviewsScheduled}',
                          Icons.calendar_today_rounded, context.colorScheme.primary),
                      _kpiCard(context, 'Interviews\nDone', '${state.interviewsDone}',
                          Icons.task_alt_rounded, context.colorScheme.secondary),
                      _kpiCard(context, 'Offers\nReceived', '${state.offersReceived}',
                          Icons.emoji_events_rounded, const Color(0xFFF59E0B)),
                      _kpiCard(context, 'Rejected', '${state.rejected}',
                          Icons.cancel_rounded, context.colorScheme.error),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // ── Salary Target ────────────────────────────────────────
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Salary Target',
                            style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        GestureDetector(
                          onTap: () => _showSalaryDialog(context, state),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(state.salaryPercent * 100).toStringAsFixed(0)}%  Edit →',
                              style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: context.screenHeight * 0.008),
                      Text(
                        state.currentSalary > 0 || state.targetSalary > 0
                            ? 'Current: ${fmt.format(state.currentSalary)}/mo  →  Target: ${fmt.format(state.targetSalary)}/mo'
                            : 'Tap "Edit" to set your salary targets',
                        style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant),
                      ),
                      SizedBox(height: context.screenHeight * 0.015),
                      LinearProgressIndicator(
                        value: state.salaryPercent,
                        backgroundColor: context.colorScheme.outlineVariant.withOpacity(0.3),
                        color: context.colorScheme.secondary,
                        minHeight: context.screenHeight * 0.008,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      if (state.targetSalary > 0) ...[
                        SizedBox(height: context.screenHeight * 0.008),
                        Text(
                          'Gap: ${fmt.format((state.targetSalary - state.currentSalary).clamp(0, double.infinity))}',
                          style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.error, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ]),
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // ── Offers Section ───────────────────────────────────────
                  if (state.offers.isNotEmpty) ...[
                    Text('🏆 Offers Received',
                        style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: context.screenHeight * 0.015),
                    ...state.offers.map((a) => _offerCard(context, a, fmt)),
                    SizedBox(height: context.screenHeight * 0.025),
                  ],

                  // ── Pipeline ─────────────────────────────────────────────
                  Text('Active Pipeline',
                      style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (state.applications.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.04),
                          child: Column(children: [
                            Icon(Icons.work_outline_rounded,
                                color: context.colorScheme.onSurfaceVariant, size: 40),
                            SizedBox(height: 12),
                            Text('No applications yet.',
                                style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
                            SizedBox(height: 4),
                            Text('Tap "Add" to log your first one.',
                                style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.outlineVariant)),
                          ]),
                        ),
                      ),
                    )
                  else
                    ...state.applications.map(
                      (app) => _pipelineCard(context, app, fmt),
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

  // ── Helper Widgets ────────────────────────────────────────────────────────

  static Widget _inputField(
    BuildContext ctx,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _kpiCard(
      BuildContext context, String title, String val, IconData icon, Color color) {
    return AppCard(
      padding: EdgeInsets.all(context.screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18),
          Text(val,
              style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title,
              style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant, height: 1.2)),
        ],
      ),
    );
  }

  Widget _offerCard(
      BuildContext context, CareerTrackerModel app, NumberFormat fmt) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.012),
      child: Container(
        padding: EdgeInsets.all(context.screenWidth * 0.04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colorScheme.secondary.withOpacity(0.15),
              context.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.br12),
          border: Border.all(color: context.colorScheme.secondary.withOpacity(0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 32),
          SizedBox(width: context.screenWidth * 0.03),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.company,
                style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            Text(app.role,
                style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant)),
          ])),
          if (app.salary > 0)
            Text(fmt.format(app.salary),
                style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.secondary)),
        ]),
      ),
    );
  }

  Widget _pipelineCard(
      BuildContext context, CareerTrackerModel app, NumberFormat fmt) {
    final Color statusColor;
    switch (app.status) {
      case 'Offer':
        statusColor = context.colorScheme.secondary;
        break;
      case 'Interview Done':
        statusColor = context.colorScheme.primary;
        break;
      case 'Interview Scheduled':
        statusColor = context.colorScheme.tertiary;
        break;
      case 'Recruiter':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'Rejected':
        statusColor = context.colorScheme.error;
        break;
      default:
        statusColor = context.colorScheme.onSurfaceVariant;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.012),
      child: GestureDetector(
        onTap: () => _showEditDialog(context, app),
        child: AppCard(
          child: Row(children: [
            Container(
              width: 4, height: context.screenHeight * 0.065,
              decoration: BoxDecoration(
                  color: statusColor, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(width: context.screenWidth * 0.035),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.company,
                    style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                Text(app.role,
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant)),
                if (app.recruiterContacted)
                  Padding(
                     padding: const EdgeInsets.only(top: 3),
                     child: Row(children: [
                       Icon(Icons.person_search_rounded,
                           size: 11, color: const Color(0xFFF59E0B)),
                       const SizedBox(width: 3),
                       Text('Recruiter contacted',
                           style: context.textTheme.labelSmall?.copyWith(
                               color: const Color(0xFFF59E0B))),
                     ]),
                  ),
                if (app.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(app.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.outlineVariant)),
                  ),
              ]),
            ),
            SizedBox(width: context.screenWidth * 0.02),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(app.status,
                    style: context.textTheme.labelSmall?.copyWith(
                        color: statusColor, fontWeight: FontWeight.bold)),
              ),
              if (app.salary > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(fmt.format(app.salary),
                      style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w500)),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}
