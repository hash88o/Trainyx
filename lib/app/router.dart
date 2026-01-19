import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/clients/presentation/pages/clients_page.dart';
import '../features/clients/presentation/pages/client_detail_page.dart';
import '../features/workouts/presentation/pages/workouts_page.dart';
import '../features/workouts/presentation/pages/active_workout_page.dart';
import '../features/workouts/presentation/pages/workout_detail_page.dart';
import '../features/templates/presentation/pages/templates_page.dart';
import '../features/templates/presentation/pages/template_editor_page.dart';
import '../features/exercises/presentation/pages/exercise_library_page.dart';
import '../features/exercises/presentation/pages/exercise_detail_page.dart';
import '../features/progress/presentation/pages/progress_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/widgets/shell/app_shell.dart';

/// Route paths
class AppRoutes {
  AppRoutes._();

  // Main tabs
  static const dashboard = '/';
  static const clients = '/clients';
  static const workouts = '/workouts';
  static const templates = '/templates';
  static const exercises = '/exercises';
  static const progress = '/progress';
  static const settings = '/settings';

  // Sub-routes
  static const clientDetail = '/clients/:id';
  static const activeWorkout = '/workouts/active';
  static const workoutDetail = '/workouts/:id';
  static const templateEditor = '/templates/edit';
  static const templateEditorWithId = '/templates/edit/:id';
  static const exerciseDetail = '/exercises/:id';

  // Helper methods for navigation
  static String clientDetailPath(String id) => '/clients/$id';
  static String workoutDetailPath(String id) => '/workouts/$id';
  static String exerciseDetailPath(String id) => '/exercises/$id';
  static String templateEditorPath([String? id]) =>
      id != null ? '/templates/edit/$id' : '/templates/edit';
}

/// Navigation keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.dashboard,
  debugLogDiagnostics: true,
  routes: [
    // Shell route for main navigation with bottom bar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.clients,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ClientsPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => ClientDetailPage(
                clientId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.workouts,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: WorkoutsPage(),
          ),
          routes: [
            GoRoute(
              path: 'active',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const ActiveWorkoutPage(),
            ),
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => WorkoutDetailPage(
                workoutId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.templates,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TemplatesPage(),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const TemplateEditorPage(),
            ),
            GoRoute(
              path: 'edit/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => TemplateEditorPage(
                templateId: state.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.exercises,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExerciseLibraryPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => ExerciseDetailPage(
                exerciseId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.progress,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProgressPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

