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

  Future<String?> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 305)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
  }

  CareerTrackerModel? _getUpcomingInterview(List<CareerTrackerModel> apps) {
    final scheduled = apps.where((a) => a.status == 'Interview Scheduled' && a.interviewDate.isNotEmpty).toList();
    if (scheduled.isEmpty) return null;
    scheduled.sort((a, b) {
      try {
        final dateA = DateFormat('dd MMM yyyy • hh:mm a').parse(a.interviewDate);
        final dateB = DateFormat('dd MMM yyyy • hh:mm a').parse(b.interviewDate);
        return dateA.compareTo(dateB);
      } catch (_) {
        return a.interviewDate.compareTo(b.interviewDate);
      }
    });
    return scheduled.first;
  }

  // ── Add Application Sheet ─────────────────────────────────────────────────
  void showAddApplicationDialog(BuildContext context) {
    final companyCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedStatus = 'Applied';
    String interviewDate = '';
    String reminderDateTime = '';

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
                if (selectedStatus == 'Interview Scheduled') ...[
                  SizedBox(height: ctx.screenHeight * 0.016),
                  GestureDetector(
                    onTap: () async {
                      final val = await _selectDateTime(ctx);
                      if (val != null) {
                        setS(() {
                          interviewDate = val;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            interviewDate.isEmpty ? 'Select Interview Date & Time' : interviewDate,
                            style: TextStyle(
                              color: interviewDate.isEmpty ? Colors.white54 : Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 18),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.016),
                  const Text('Reminder Date & Time (Optional)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final val = await _selectDateTime(ctx);
                      if (val != null) {
                        setS(() {
                          reminderDateTime = val;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminderDateTime.isEmpty ? 'Select Custom Reminder Time' : reminderDateTime,
                              style: TextStyle(
                                color: reminderDateTime.isEmpty ? Colors.white54 : Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (reminderDateTime.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setS(() {
                                  reminderDateTime = '';
                                });
                              },
                              child: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.alarm_rounded, color: Colors.white54, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: ctx.screenHeight * 0.016),
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
                        recruiterContacted: false,
                        interviewDate: interviewDate,
                        notes: notesCtrl.text.trim(),
                        reminderDateTime: reminderDateTime,
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

  // ── Edit Application Sheet (Status Focus & History Timeline) ─────────────
  void _showEditDialog(BuildContext context, CareerTrackerModel app) {
    final offeredSalaryCtrl = TextEditingController(
        text: app.offeredSalary > 0 ? app.offeredSalary.toStringAsFixed(0) : '');
    String selectedStatus = app.status;
    String interviewDate = app.interviewDate;
    String reminderDateTime = app.reminderDateTime;
    final bloc = context.read<CareerTrackerBloc>();
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: StatefulBuilder(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.company,
                              style: ctx.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              app.role,
                              style: ctx.textTheme.bodyMedium?.copyWith(
                                  color: ctx.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          bloc.add(CareerTrackerApplicationDeleted(id: app.id));
                          HapticFeedback.mediumImpact();
                        },
                        icon: Icon(Icons.delete_outline_rounded,
                            color: ctx.colorScheme.error),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  
                  // Read-only Details
                  if (app.salary > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Target Salary:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        Text(fmt.format(app.salary), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (app.notes.isNotEmpty) ...[
                    const Text('Notes:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(app.notes, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                  ],
                  
                  // Edit Status dropdown
                  const Text('Update Pipeline Status', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: ctx.colorScheme.surface,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Applied', child: Text('Applied')),
                      DropdownMenuItem(value: 'Recruiter', child: Text('Recruiter Contacted')),
                      DropdownMenuItem(value: 'Interview Scheduled', child: Text('Interview Scheduled')),
                      DropdownMenuItem(value: 'Interview Done', child: Text('Interview Done')),
                      DropdownMenuItem(value: 'Offer', child: Text('Offer Received')),
                      DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setS(() {
                          selectedStatus = v;
                        });
                      }
                    },
                  ),
                  
                  // Offered Salary Tile (Only show when status is 'Offer')
                  if (selectedStatus == 'Offer') ...[
                    SizedBox(height: ctx.screenHeight * 0.02),
                    const Text('Offered Salary (₹/mo)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: offeredSalaryCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter offered salary',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                  
                  // Interview Date & Time Tile (Only show when status is 'Interview Scheduled')
                  if (selectedStatus == 'Interview Scheduled') ...[
                    SizedBox(height: ctx.screenHeight * 0.02),
                    const Text('Interview Date & Time', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final val = await _selectDateTime(ctx);
                        if (val != null) {
                          setS(() {
                            interviewDate = val;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              interviewDate.isEmpty ? 'Select Date & Time' : interviewDate,
                              style: TextStyle(
                                color: interviewDate.isEmpty ? Colors.white54 : Colors.white,
                              ),
                            ),
                            const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ctx.screenHeight * 0.016),
                    const Text('Reminder Date & Time (Optional)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final val = await _selectDateTime(ctx);
                        if (val != null) {
                          setS(() {
                            reminderDateTime = val;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminderDateTime.isEmpty ? 'Select Custom Reminder Time' : reminderDateTime,
                                style: TextStyle(
                                  color: reminderDateTime.isEmpty ? Colors.white54 : Colors.white,
                                ),
                              ),
                            ),
                            if (reminderDateTime.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setS(() {
                                    reminderDateTime = '';
                                  });
                                },
                                child: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                              ),
                            const SizedBox(width: 8),
                            const Icon(Icons.alarm_rounded, color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const Divider(color: Colors.white12, height: 32),
                  
                  // Timeline status history list
                  const Text('Status History', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  FutureBuilder<List<CareerStatusHistoryModel>>(
                    future: bloc.getStatusHistory(app.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      final history = snapshot.data ?? [];
                      if (history.isEmpty) {
                        return const Text('No history found', style: TextStyle(color: Colors.white54, fontSize: 12));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: history.length,
                        itemBuilder: (context, idx) {
                          final hist = history[idx];
                          final timeStr = DateFormat('dd MMM yyyy • hh:mm a').format(hist.changedAt);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  idx == history.length - 1 ? Icons.check_circle_rounded : Icons.radio_button_checked_rounded,
                                  size: 16,
                                  color: idx == history.length - 1 ? ctx.colorScheme.primary : Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hist.status == 'Recruiter' ? 'Recruiter Contacted' : (hist.status == 'Offer' ? 'Offer Received' : hist.status),
                                        style: TextStyle(
                                          color: idx == history.length - 1 ? Colors.white : Colors.white70,
                                          fontWeight: idx == history.length - 1 ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(color: Colors.white30, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  SizedBox(height: ctx.screenHeight * 0.03),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: ctx.screenHeight * 0.055,
                    child: ElevatedButton(
                      onPressed: () {
                        final offeredSal = double.tryParse(offeredSalaryCtrl.text.trim()) ?? 0.0;
                        final updated = app.copyWith(
                          status: selectedStatus,
                          offeredSalary: offeredSal,
                          interviewDate: selectedStatus == 'Interview Scheduled' ? interviewDate : '',
                          reminderDateTime: selectedStatus == 'Interview Scheduled' ? reminderDateTime : '',
                        );
                        bloc.add(CareerTrackerApplicationUpdated(model: updated));
                        HapticFeedback.mediumImpact();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctx.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.br12)),
                      ),
                      child: const Text('Save Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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

                  // ── Upcoming Interview Banner ─────────────────────────────
                  if (_getUpcomingInterview(state.applications) != null) ...[
                    (() {
                      final upcoming = _getUpcomingInterview(state.applications)!;
                      return Container(
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
                                    '${upcoming.company} • ${upcoming.role}',
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    upcoming.interviewDate,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })(),
                    SizedBox(height: context.screenHeight * 0.03),
                  ],

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
          if (app.offeredSalary > 0)
            Text(fmt.format(app.offeredSalary),
                style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.secondary))
          else if (app.salary > 0)
            Text(fmt.format(app.salary),
                style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.secondary.withOpacity(0.6))),
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
                if (app.status == 'Interview Scheduled' && app.interviewDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event_note_rounded, size: 13, color: context.colorScheme.tertiary),
                      const SizedBox(width: 4),
                      Text(
                        app.interviewDate,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ] else if (app.notes.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(app.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.outlineVariant)),
                  ),
                ],
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
                child: Text(
                  app.status == 'Recruiter' ? 'Recruiter' : app.status,
                  style: context.textTheme.labelSmall?.copyWith(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
              if (app.status == 'Offer' && app.offeredSalary > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(fmt.format(app.offeredSalary),
                      style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.secondary, fontWeight: FontWeight.bold)),
                )
              else if (app.salary > 0)
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
