import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../models/youtube_tracker_model.dart';
import '../bloc/youtube_tracker_bloc.dart';
import '../bloc/youtube_tracker_event.dart';
import '../bloc/youtube_tracker_state.dart';

const _ytRed = Color(0xFFFF0000);

class YoutubeTrackerPage extends StatelessWidget {
  const YoutubeTrackerPage({super.key});

  void showAddVideoDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    String selectedType = 'Long';
    String selectedStage = 'Script';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: ctx.screenWidth * 0.12, height: 4,
                  decoration: BoxDecoration(color: ctx.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: ctx.screenHeight * 0.02),
              Text('Log New Video', style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: ctx.screenHeight * 0.025),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Video Title', border: OutlineInputBorder()),
              ),
              SizedBox(height: ctx.screenHeight * 0.02),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: ctx.colorScheme.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Short', child: Text('Short')),
                    DropdownMenuItem(value: 'Long', child: Text('Long')),
                  ],
                  onChanged: (v) { if (v != null) setS(() => selectedType = v); },
                )),
                SizedBox(width: ctx.screenWidth * 0.03),
                Expanded(child: DropdownButtonFormField<String>(
                  value: selectedStage,
                  dropdownColor: ctx.colorScheme.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Stage', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Script', child: Text('Script')),
                    DropdownMenuItem(value: 'Recording', child: Text('Recording')),
                    DropdownMenuItem(value: 'Editing', child: Text('Editing')),
                    DropdownMenuItem(value: 'Published', child: Text('Published')),
                  ],
                  onChanged: (v) { if (v != null) setS(() => selectedStage = v); },
                )),
              ]),
              SizedBox(height: ctx.screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: ctx.screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    if (t.isNotEmpty) {
                      context.read<YoutubeTrackerBloc>().add(YoutubeTrackerVideoAdded(
                        title: t,
                        type: selectedType,
                        stage: selectedStage,
                        views: 0,
                        watchTimeMinutes: 0,
                      ));
                      HapticFeedback.mediumImpact();
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ytRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                  ),
                  child: const Text('Add to Pipeline', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCalendarEntryDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    String selectedType = 'Long';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: context.colorScheme.surface,
          title: const Text('Add Calendar Entry', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Content Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: context.colorScheme.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Short', child: Text('Short')),
                  DropdownMenuItem(value: 'Long', child: Text('Long')),
                ],
                onChanged: (v) { if (v != null) setS(() => selectedType = v); },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}', style: const TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 120)),
                      );
                      if (picked != null) setS(() => selectedDate = picked);
                    },
                    child: const Text('Select'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isNotEmpty) {
                  context.read<YoutubeTrackerBloc>().add(YoutubeTrackerCalendarEntryAdded(
                    title: t,
                    type: selectedType,
                    scheduledDate: selectedDate,
                  ));
                  HapticFeedback.mediumImpact();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscribersDialog(BuildContext context, int currentSubs) {
    final ctrl = TextEditingController(text: currentSubs.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colorScheme.surface,
        title: const Text('Update Subscribers', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Subscribers count', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final count = int.tryParse(ctrl.text.trim()) ?? currentSubs;
              context.read<YoutubeTrackerBloc>().add(YoutubeTrackerSubscribersUpdated(subscribers: count));
              HapticFeedback.mediumImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditVideoDialog(BuildContext context, YoutubeVideoModel v) {
    final viewsCtrl = TextEditingController(text: v.views.toString());
    final watchTimeCtrl = TextEditingController(text: v.watchTimeMinutes.toString());
    String selectedStage = v.stage;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: ctx.screenWidth * 0.12, height: 4,
                  decoration: BoxDecoration(color: ctx.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: ctx.screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Edit "${v.title}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<YoutubeTrackerBloc>().add(YoutubeTrackerVideoDeleted(id: v.id));
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                    },
                    icon: Icon(Icons.delete_outline_rounded, color: ctx.colorScheme.error),
                  ),
                ],
              ),
              SizedBox(height: ctx.screenHeight * 0.02),
              DropdownButtonFormField<String>(
                value: selectedStage,
                dropdownColor: ctx.colorScheme.surface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Pipeline Stage', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Script', child: Text('Script')),
                  DropdownMenuItem(value: 'Recording', child: Text('Recording')),
                  DropdownMenuItem(value: 'Editing', child: Text('Editing')),
                  DropdownMenuItem(value: 'Published', child: Text('Published')),
                ],
                onChanged: (val) { if (val != null) setS(() => selectedStage = val); },
              ),
              if (selectedStage == 'Published') ...[
                SizedBox(height: ctx.screenHeight * 0.02),
                TextField(
                  controller: viewsCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Views count', border: OutlineInputBorder()),
                ),
                SizedBox(height: ctx.screenHeight * 0.02),
                TextField(
                  controller: watchTimeCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Watch Time (minutes)', border: OutlineInputBorder()),
                ),
              ],
              SizedBox(height: ctx.screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                height: ctx.screenHeight * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    final views = int.tryParse(viewsCtrl.text.trim()) ?? 0;
                    final wt = int.tryParse(watchTimeCtrl.text.trim()) ?? 0;
                    final updated = v.copyWith(
                      stage: selectedStage,
                      views: selectedStage == 'Published' ? views : 0,
                      watchTimeMinutes: selectedStage == 'Published' ? wt : 0,
                    );
                    context.read<YoutubeTrackerBloc>().add(YoutubeTrackerVideoUpdated(model: updated));
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ytRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeTrackerBloc, YoutubeTrackerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AppLoader();
        }
        if (state.errorMessage != null && state.settings == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.screenWidth * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, color: context.colorScheme.error, size: AppSizes.icon48),
                  SizedBox(height: context.screenHeight * 0.02),
                  Text(state.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: context.colorScheme.error)),
                ],
              ),
            ),
          );
        }

        final watchHours = (state.watchTimeMinutes / 60).round();
        final published = state.publishedVideos;
        final pipeline = state.pipelineVideos;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('YouTube Studio',
                            style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: context.screenHeight * 0.005),
                        Text('Build your content velocity machine.',
                            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                      ]),
                      IconButton(
                        onPressed: () => showAddVideoDialog(context),
                        style: IconButton.styleFrom(
                            backgroundColor: _ytRed, foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(AppSizes.padding12)),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Channel Momentum Hero ─────────────────────────────
                  GestureDetector(
                    onTap: () => _showSubscribersDialog(context, state.subscribers),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(context.screenWidth * 0.05),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_ytRed.withOpacity(0.18), context.colorScheme.surface],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.br16),
                        border: Border.all(color: _ytRed.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('SUBSCRIBERS', style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                            SizedBox(height: context.screenHeight * 0.006),
                            Text(_fmt(state.subscribers),
                                style: context.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                          ]),
                          const Spacer(),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            _heroChip(context, Icons.visibility_rounded, '${_fmt(state.totalViews)} views'),
                            SizedBox(height: context.screenHeight * 0.01),
                            _heroChip(context, Icons.timer_rounded, '$watchHours hrs watch time'),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Stats Grid (6 KPIs) ───────────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: context.screenWidth * 0.03,
                    mainAxisSpacing: context.screenWidth * 0.03,
                    childAspectRatio: 1.1,
                    children: [
                      _kpiCard(context, 'Scripts\nWritten', '${state.scriptsWritten}', Icons.edit_note_rounded, _ytRed),
                      _kpiCard(context, 'Shorts\nUploaded', '${state.shortsUploaded}', Icons.bolt_rounded, context.colorScheme.tertiary),
                      _kpiCard(context, 'Long Videos\nUploaded', '${state.longsUploaded}', Icons.video_library_rounded, context.colorScheme.primary),
                      _kpiCard(context, 'Total\nViews', _fmt(state.totalViews), Icons.visibility_rounded, context.colorScheme.secondary),
                      _kpiCard(context, 'Watch Time\n(hrs)', '$watchHours', Icons.timer_rounded, _ytRed),
                      _kpiCard(context, 'In\nPipeline', '${state.inPipeline}', Icons.pending_actions_rounded, context.colorScheme.tertiary),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.03),

                  // ── Published Videos ──────────────────────────────────
                  Text('Published Videos', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (published.isEmpty)
                    AppCard(child: Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.02),
                      child: Text('No videos published yet.', style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
                    )))
                  else
                    ...published.map((v) => _videoCard(context, v)),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Production Pipeline ───────────────────────────────
                  Text('Production Pipeline', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (pipeline.isEmpty)
                    AppCard(child: Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.02),
                      child: Text('No videos in pipeline.', style: TextStyle(color: context.colorScheme.onSurfaceVariant)),
                    )))
                  else
                    ...pipeline.map((v) => _pipelineCard(context, v)),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Content Calendar ──────────────────────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Content Calendar', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      onPressed: () => _showAddCalendarEntryDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                    ),
                  ]),
                  SizedBox(height: context.screenHeight * 0.015),
                  AppCard(
                    child: Column(
                      children: state.calendarEntries.isEmpty
                          ? [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.02),
                                child: Center(child: Text('No scheduled entries.', style: TextStyle(color: context.colorScheme.onSurfaceVariant))),
                              )
                            ]
                          : state.calendarEntries.map((entry) {
                              final daysLeft = entry.scheduledDate.difference(DateTime.now()).inDays;
                              return Padding(
                                padding: EdgeInsets.only(bottom: context.screenHeight * 0.015),
                                child: Row(children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: entry.isPublished
                                          ? context.colorScheme.secondary.withOpacity(0.12)
                                          : _ytRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      entry.type == 'Short' ? Icons.bolt_rounded : Icons.video_library_rounded,
                                      color: entry.isPublished ? context.colorScheme.secondary : _ytRed,
                                      size: 22,
                                    ),
                                  ),
                                  SizedBox(width: context.screenWidth * 0.035),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(entry.title,
                                        style: context.textTheme.bodyMedium?.copyWith(
                                            color: Colors.white, fontWeight: FontWeight.w600),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(
                                      entry.isPublished
                                          ? '✓ Published'
                                          : daysLeft <= 0 ? 'Due today!' : 'In $daysLeft days • ${entry.type}',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: entry.isPublished
                                            ? context.colorScheme.secondary
                                            : daysLeft <= 2 ? _ytRed : context.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ])),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: context.colorScheme.error.withOpacity(0.7), size: 20),
                                    onPressed: () {
                                      context.read<YoutubeTrackerBloc>().add(YoutubeTrackerCalendarEntryDeleted(id: entry.id));
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<YoutubeTrackerBloc>().add(YoutubeTrackerCalendarEntryToggled(id: entry.id));
                                      HapticFeedback.lightImpact();
                                    },
                                    child: Container(
                                      width: 28, height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: entry.isPublished ? context.colorScheme.secondary : context.colorScheme.outlineVariant,
                                          width: 2,
                                        ),
                                        color: entry.isPublished ? context.colorScheme.secondary : Colors.transparent,
                                      ),
                                      child: entry.isPublished
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                          : null,
                                      ),
                                    ),
                                  ]),
                                );
                              }).toList(),
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

  Widget _heroChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.screenWidth * 0.025, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _ytRed, size: 14),
        SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _kpiCard(BuildContext context, String title, String val, IconData icon, Color color) {
    return AppCard(
      padding: EdgeInsets.all(context.screenWidth * 0.025),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: color, size: 18),
        Text(val, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        Text(title, style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant, height: 1.2)),
      ]),
    );
  }

  Widget _videoCard(BuildContext context, YoutubeVideoModel v) {
    final watchHrs = (v.watchTimeMinutes / 60).toStringAsFixed(1);
    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.012),
      child: GestureDetector(
        onTap: () => _showEditVideoDialog(context, v),
        child: AppCard(
          child: Row(children: [
            Container(
              width: 4, height: context.screenHeight * 0.065,
              decoration: BoxDecoration(color: _ytRed, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(width: context.screenWidth * 0.035),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.title,
                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2),
              Text('${_fmt(v.views)} views  •  $watchHrs hrs  •  ${v.type}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: v.type == 'Short' ? context.colorScheme.tertiary.withOpacity(0.12) : _ytRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(v.type,
                  style: context.textTheme.labelSmall?.copyWith(
                      color: v.type == 'Short' ? context.colorScheme.tertiary : _ytRed,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pipelineCard(BuildContext context, YoutubeVideoModel v) {
    final Color stageColor;
    switch (v.stage) {
      case 'Editing': stageColor = context.colorScheme.primary; break;
      case 'Recording': stageColor = context.colorScheme.tertiary; break;
      default: stageColor = context.colorScheme.onSurfaceVariant;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: context.screenHeight * 0.012),
      child: GestureDetector(
        onTap: () => _showEditVideoDialog(context, v),
        child: AppCard(
          child: Row(children: [
            Container(
              width: 4, height: context.screenHeight * 0.055,
              decoration: BoxDecoration(color: stageColor, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(width: context.screenWidth * 0.035),
            Expanded(child: Text(v.title,
                style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            SizedBox(width: context.screenWidth * 0.02),
            _stageBadge(context, v.stage, stageColor),
          ]),
        ),
      ),
    );
  }

  Widget _stageBadge(BuildContext context, String stage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(stage, style: context.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
