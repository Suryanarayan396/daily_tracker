// lib/routes/app_router.dart

import 'package:go_router/go_router.dart';
import '../shared/widgets/main_navigation_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        return const MainNavigationPage();
      },
    ),
  ],
);
