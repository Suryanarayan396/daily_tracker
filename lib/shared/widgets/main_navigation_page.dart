import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extension.dart';
import '../../core/services/life_os_repository.dart';
import '../../features/career_tracker/views/career_tracker_page.dart';
import '../../features/daily_reflection/views/daily_reflection_page.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/dashboard/bloc/dashboard_event.dart';
import '../../features/dashboard/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import '../../features/finance_tracker/views/finance_tracker_page.dart';
import '../../features/learning_tracker/views/learning_tracker_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Tab 0: Dashboard (wrapped in BlocProvider for compatibility)
    BlocProvider(
      create: (_) => DashboardBloc(DashboardRepositoryImpl())..add(const DashboardStarted()),
      child: const DashboardPage(),
    ),
    // Tab 1: Career
    const CareerTrackerPage(),
    // Tab 2: Finance
    const FinanceTrackerPage(),
    // Tab 3: Learning
    const LearningTrackerPage(),
    // Tab 4: Reflection
    const DailyReflectionPage(),
  ];

  void _showFabMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.br24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: context.screenHeight * 0.025,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Log Engine',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.screenHeight * 0.02),
              ListTile(
                leading: Icon(Icons.send_rounded, color: context.colorScheme.primary),
                title: const Text('Add Job Application', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Trigger add dialog on Career Tab
                  setState(() => _currentIndex = 1);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    const CareerTrackerPage().showAddApplicationDialog(context);
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.timer_outlined, color: context.colorScheme.secondary),
                title: const Text('Log Learning Session', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Trigger log session on Learning Tab
                  setState(() => _currentIndex = 3);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    const LearningTrackerPage().showLogSessionDialog(context, LifeOSRepository());
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.rate_review_rounded, color: context.colorScheme.tertiary),
                title: const Text('Write Daily Reflection', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Switch to Reflection Tab
                  setState(() => _currentIndex = 4);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0D0E11),
          indicatorColor: context.colorScheme.primary.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }
            return TextStyle(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: context.colorScheme.primary);
            }
            return IconThemeData(color: context.colorScheme.onSurfaceVariant);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            HapticFeedback.lightImpact();
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_rounded),
              label: 'Career',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Finance',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Learning',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_rounded),
              label: 'Reflection',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFabMenu(context),
        backgroundColor: context.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
