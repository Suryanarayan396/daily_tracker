import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/career_tracker/bloc/career_tracker_bloc.dart';
import '../features/career_tracker/bloc/career_tracker_event.dart';
import '../features/career_tracker/repositories/career_tracker_repository_impl.dart';
import '../features/dashboard/bloc/dashboard_bloc.dart';
import '../features/dashboard/bloc/dashboard_event.dart';
import '../features/dashboard/repositories/dashboard_repository_impl.dart';
import '../features/finance_tracker/bloc/finance_tracker_bloc.dart';
import '../features/finance_tracker/bloc/finance_tracker_event.dart';
import '../features/finance_tracker/repositories/finance_tracker_repository_impl.dart';
import '../features/youtube_tracker/bloc/youtube_tracker_bloc.dart';
import '../features/youtube_tracker/bloc/youtube_tracker_event.dart';
import '../features/youtube_tracker/repositories/youtube_tracker_repository_impl.dart';
import '../shared/widgets/main_navigation_page.dart';

import '../features/splash/views/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => DashboardBloc(const DashboardRepositoryImpl())..add(const DashboardStarted()),
            ),
            BlocProvider(
              create: (_) => CareerTrackerBloc(const CareerTrackerRepositoryImpl())..add(const CareerTrackerStarted()),
            ),
            BlocProvider(
              create: (_) => FinanceTrackerBloc(const FinanceTrackerRepositoryImpl())..add(const FinanceTrackerStarted()),
            ),
            BlocProvider(
              create: (_) => YoutubeTrackerBloc(const YoutubeTrackerRepositoryImpl())..add(const YoutubeTrackerStarted()),
            ),
          ],
          child: const MainNavigationPage(),
        );
      },
    ),
  ],
);
