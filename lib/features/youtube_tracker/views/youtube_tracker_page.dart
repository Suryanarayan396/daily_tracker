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

class YoutubeTrackerPage extends StatelessWidget {
  const YoutubeTrackerPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeTrackerBloc, YoutubeTrackerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AppLoader();
        }

        if (state.errorMessage != null && state.contentList.isEmpty) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(context.screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, color: context.colorScheme.error, size: AppSizes.icon48),
                    SizedBox(height: context.screenHeight * 0.02),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final planned = state.plannedContent;
        final pipeline = state.pipelineContent;
        final published = state.publishedContent;

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YouTube Studio',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.005),
                          Text(
                            'Build your content velocity machine.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.025),

                  // ── Channel Stats Tiles ─────────────────────────────────
                  _buildChannelStatsRow(context, state.stats),
                  SizedBox(height: context.screenHeight * 0.03),

                  // ── Content Calendar Section ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Content Calendar',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddContentBottomSheet(context),
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: context.colorScheme.primary,
                          size: 24,
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (planned.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.03),
                          child: Text(
                            'No planned content. Tap + to add.',
                            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: planned.length,
                        itemBuilder: (context, index) {
                          return _buildContentCalendarCard(context, planned[index]);
                        },
                      ),
                    ),
                  SizedBox(height: context.screenHeight * 0.035),

                  // ── Production Pipeline Section ─────────────────────────
                  Text(
                    'Production Pipeline',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (pipeline.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.03),
                          child: Text(
                            'No videos in production pipeline.',
                            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pipeline.length,
                        itemBuilder: (context, index) {
                          return _buildProductionPipelineCard(context, pipeline[index]);
                        },
                      ),
                    ),
                  SizedBox(height: context.screenHeight * 0.035),

                  // ── Published Videos Section ────────────────────────────
                  Text(
                    'Published Videos',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.015),
                  if (published.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: context.screenHeight * 0.03),
                          child: Text(
                            'No published videos yet.',
                            style: TextStyle(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: published.length,
                      itemBuilder: (context, index) {
                        return _buildPublishedVideoTile(context, published[index]);
                      },
                    ),
                  SizedBox(height: context.screenHeight * 0.04),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Stats ListView Builder ──────────────────────────────────────────────
  Widget _buildChannelStatsRow(BuildContext context, YoutubeChannelStatsModel stats) {
    final items = [
      {'key': 'subscribers', 'label': 'Subscribers', 'value': stats.subscribers, 'icon': Icons.people_rounded},
      {'key': 'views', 'label': 'Total Views', 'value': stats.totalViews, 'icon': Icons.visibility_rounded},
      {'key': 'videos', 'label': 'Total Videos', 'value': stats.totalVideos, 'icon': Icons.video_collection_rounded},
      {'key': 'watch_hours', 'label': 'Watch Hours', 'value': stats.watchHours, 'icon': Icons.timer_rounded},
      {'key': 'monthly_revenue', 'label': 'Monthly Revenue', 'value': stats.monthlyRevenue, 'icon': Icons.monetization_on_rounded},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => _showUpdateStatBottomSheet(context, item['key'] as String, item['value'] as String),
              borderRadius: BorderRadius.circular(AppSizes.br16),
              child: Ink(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSizes.br16),
                  border: Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['label'] as String,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          item['icon'] as IconData,
                          color: context.colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      item['value'] as String,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Stat Update Bottom Sheet ───────────────────────────────────────────
  void _showUpdateStatBottomSheet(BuildContext context, String key, String currentValue) {
    final bloc = context.read<YoutubeTrackerBloc>();
    final ctrl = TextEditingController(text: currentValue);
    final label = key.replaceAll('_', ' ').toUpperCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Padding(
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
                Center(
                  child: Container(
                    width: ctx.screenWidth * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: ctx.screenHeight * 0.02),
                Text(
                  'Update $label',
                  style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: ctx.screenHeight * 0.025),
                TextField(
                  controller: ctrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'New Value',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ctx.colorScheme.primary)),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: ctx.screenHeight * 0.03),
                SizedBox(
                  width: double.infinity,
                  height: ctx.screenHeight * 0.055,
                  child: ElevatedButton(
                    onPressed: () {
                      final val = ctrl.text.trim();
                      if (val.isNotEmpty) {
                        bloc.add(YoutubeTrackerStatUpdated(key: key, value: val));
                        HapticFeedback.mediumImpact();
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctx.colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                    ),
                    child: const Text('Update Stat', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Content Calendar Card Builder ──────────────────────────────────────
  Widget _buildContentCalendarCard(BuildContext context, YoutubeContentModel item) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => _showCalendarEntryOptionsBottomSheet(context, item),
        borderRadius: BorderRadius.circular(AppSizes.br16),
        child: Ink(
          width: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSizes.br16),
            border: Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('d MMM yyyy').format(DateTime.tryParse(item.targetDate) ?? DateTime.now()),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Calendar Entry Options Bottom Sheet ────────────────────────────────
  void _showCalendarEntryOptionsBottomSheet(BuildContext context, YoutubeContentModel item) {
    final bloc = context.read<YoutubeTrackerBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ctx.screenWidth * 0.05,
            vertical: ctx.screenHeight * 0.03,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Center(
                child: Container(
                  width: ctx.screenWidth * 0.12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ctx.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: ctx.screenHeight * 0.02),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: ctx.colorScheme.primary),
                title: const Text('Edit Entry', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Change title or target date', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditContentBottomSheet(context, item);
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.rocket_launch_rounded, color: Colors.orange),
                title: const Text('Move to Production Pipeline', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Change status to Scripting', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  final updated = item.copyWith(status: 'scripting');
                  bloc.add(YoutubeTrackerContentUpdated(content: updated));
                  HapticFeedback.mediumImpact();
                  Navigator.pop(ctx);
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: ctx.colorScheme.error),
                title: Text('Delete Entry', style: TextStyle(color: ctx.colorScheme.error)),
                onTap: () {
                  bloc.add(YoutubeTrackerContentDeleted(id: item.id));
                  HapticFeedback.heavyImpact();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
       ),
      ),
    );
  }

  // ── Edit Planned Content Bottom Sheet ──────────────────────────────────
  void _showEditContentBottomSheet(BuildContext context, YoutubeContentModel item) {
    final bloc = context.read<YoutubeTrackerBloc>();
    final titleCtrl = TextEditingController(text: item.title);
    DateTime selectedDate = DateTime.tryParse(item.targetDate) ?? DateTime.now();
    String reminderDateTime = item.reminderDateTime;

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
          builder: (context, setState) => Padding(
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
                  Center(
                    child: Container(
                      width: ctx.screenWidth * 0.12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ctx.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.02),
                  Text(
                    'Edit Planned Content',
                    style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.025),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Content Title', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.02),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Target Date',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                      ),
                      child: Text(
                        DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.02),
                  const Text('Reminder Date & Time (Optional)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final val = await _selectDateTime(ctx);
                      if (val != null) {
                        setState(() {
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
                                setState(() {
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
                  SizedBox(height: ctx.screenHeight * 0.03),
                  SizedBox(
                    width: double.infinity,
                    height: ctx.screenHeight * 0.055,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isNotEmpty) {
                          final updated = item.copyWith(
                            title: title,
                            targetDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                            reminderDateTime: reminderDateTime,
                          );
                          bloc.add(YoutubeTrackerContentUpdated(content: updated));
                          HapticFeedback.mediumImpact();
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctx.colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Add Content Bottom Sheet ───────────────────────────────────────────
  void _showAddContentBottomSheet(BuildContext context) {
    final bloc = context.read<YoutubeTrackerBloc>();
    final titleCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String reminderDateTime = '';

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
          builder: (context, setState) => Padding(
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
                  Center(
                    child: Container(
                      width: ctx.screenWidth * 0.12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ctx.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.02),
                  Text(
                    'Add Planned Content',
                    style: ctx.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.025),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Content Title', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.02),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Target Upload Date',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                      ),
                      child: Text(
                        DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: ctx.screenHeight * 0.02),
                  const Text('Reminder Date & Time (Optional)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final val = await _selectDateTime(ctx);
                      if (val != null) {
                        setState(() {
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
                                setState(() {
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
                  SizedBox(height: ctx.screenHeight * 0.03),
                  SizedBox(
                    width: double.infinity,
                    height: ctx.screenHeight * 0.055,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isNotEmpty) {
                          bloc.add(YoutubeTrackerContentAdded(
                            title: title,
                            targetDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                            reminderDateTime: reminderDateTime,
                          ));
                          HapticFeedback.mediumImpact();
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctx.colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.br12)),
                      ),
                      child: const Text('Add to Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Production Pipeline Card Builder ───────────────────────────────────
  Widget _buildProductionPipelineCard(BuildContext context, YoutubeContentModel item) {
    Color chipColor;
    switch (item.status) {
      case 'scripting':
        chipColor = Colors.blue;
        break;
      case 'filming':
        chipColor = Colors.orange;
        break;
      case 'editing':
        chipColor = Colors.purple;
        break;
      case 'thumbnail':
        chipColor = Colors.teal;
        break;
      default:
        chipColor = Colors.white24;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => _showPipelineEntryOptionsBottomSheet(context, item),
        borderRadius: BorderRadius.circular(AppSizes.br16),
        child: Ink(
          width: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSizes.br16),
            border: Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('d MMM yyyy').format(DateTime.tryParse(item.targetDate) ?? DateTime.now()),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: chipColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: chipColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Production Pipeline Options Bottom Sheet ───────────────────────────
  void _showPipelineEntryOptionsBottomSheet(BuildContext context, YoutubeContentModel item) {
    final bloc = context.read<YoutubeTrackerBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ctx.screenWidth * 0.05,
            vertical: ctx.screenHeight * 0.03,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: ctx.screenWidth * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: ctx.screenHeight * 0.02),
                Text(
                  'Pipeline Progress: ${item.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Change Stage',
                  style: ctx.textTheme.labelMedium?.copyWith(
                    color: ctx.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.description_rounded, color: Colors.blue),
                  title: const Text('Scripting', style: TextStyle(color: Colors.white)),
                  trailing: item.status == 'scripting' ? const Icon(Icons.check_circle_rounded, color: Colors.blue) : null,
                  onTap: () {
                    bloc.add(YoutubeTrackerContentUpdated(content: item.copyWith(status: 'scripting')));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam_rounded, color: Colors.orange),
                  title: const Text('Filming', style: TextStyle(color: Colors.white)),
                  trailing: item.status == 'filming' ? const Icon(Icons.check_circle_rounded, color: Colors.orange) : null,
                  onTap: () {
                    bloc.add(YoutubeTrackerContentUpdated(content: item.copyWith(status: 'filming')));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.movie_filter_rounded, color: Colors.purple),
                  title: const Text('Editing', style: TextStyle(color: Colors.white)),
                  trailing: item.status == 'editing' ? const Icon(Icons.check_circle_rounded, color: Colors.purple) : null,
                  onTap: () {
                    bloc.add(YoutubeTrackerContentUpdated(content: item.copyWith(status: 'editing')));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image_rounded, color: Colors.teal),
                  title: const Text('Thumbnail', style: TextStyle(color: Colors.white)),
                  trailing: item.status == 'thumbnail' ? const Icon(Icons.check_circle_rounded, color: Colors.teal) : null,
                  onTap: () {
                    bloc.add(YoutubeTrackerContentUpdated(content: item.copyWith(status: 'thumbnail')));
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
                  title: const Text('Mark as Published', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Move to Published Videos', style: TextStyle(color: Colors.white54)),
                  onTap: () {
                    bloc.add(YoutubeTrackerContentUpdated(
                      content: item.copyWith(
                        status: 'published',
                        publishedAt: DateTime.now(),
                      ),
                    ));
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: ctx.colorScheme.error),
                  title: Text('Delete Video', style: TextStyle(color: ctx.colorScheme.error)),
                  onTap: () {
                    bloc.add(YoutubeTrackerContentDeleted(id: item.id));
                    HapticFeedback.heavyImpact();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Published Video Tile Builder ───────────────────────────────────────
  Widget _buildPublishedVideoTile(BuildContext context, YoutubeContentModel item) {
    final pubDate = item.publishedAt ?? item.createdAt;
    final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(pubDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showPublishedOptionsBottomSheet(context, item),
        borderRadius: BorderRadius.circular(AppSizes.br16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSizes.br16),
            border: Border.all(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: context.textTheme.bodySmall?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  'PUBLISHED',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Published Video Options Bottom Sheet ───────────────────────────────
  void _showPublishedOptionsBottomSheet(BuildContext context, YoutubeContentModel item) {
    final bloc = context.read<YoutubeTrackerBloc>();
    final pubDate = item.publishedAt ?? item.createdAt;
    final formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(pubDate);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ctx.screenWidth * 0.05,
            vertical: ctx.screenHeight * 0.03,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: ctx.screenWidth * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: ctx.screenHeight * 0.02),
                Text(
                  'Published Video Details',
                  style: ctx.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text('Title:', style: ctx.textTheme.labelSmall?.copyWith(color: ctx.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Published On:', style: ctx.textTheme.labelSmall?.copyWith(color: ctx.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: ctx.colorScheme.error),
                  title: Text('Delete Video Entry', style: TextStyle(color: ctx.colorScheme.error)),
                  onTap: () {
                    bloc.add(YoutubeTrackerContentDeleted(id: item.id));
                    HapticFeedback.heavyImpact();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
