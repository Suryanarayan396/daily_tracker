import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/extensions/context_extension.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import '../../features/career_tracker/views/career_tracker_page.dart';
import '../../features/finance_tracker/views/finance_tracker_page.dart';
import '../../features/youtube_tracker/views/youtube_tracker_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CareerTrackerPage(),
    FinanceTrackerPage(),
    YoutubeTrackerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF13151A),
          elevation: 12,
          indicatorColor: context.colorScheme.primary.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                fontFamily: 'Inter',
              );
            }
            return TextStyle(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontFamily: 'Inter',
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: context.colorScheme.primary, size: 24);
            }
            return IconThemeData(color: context.colorScheme.onSurfaceVariant, size: 24);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          height: context.screenHeight * 0.075,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
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
              icon: Icon(Icons.play_circle_fill_rounded),
              label: 'YouTube',
            ),
          ],
        ),
      ),
    );
  }
}
