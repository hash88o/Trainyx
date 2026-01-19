import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'core/theme/app_theme.dart';
import 'database/database.dart';
import 'database/failed_migrations_page.dart';
import 'constants.dart';
import 'plan/plan_state.dart';
import 'settings/settings_state.dart';
import 'timer/timer_state.dart';
import 'workouts/workout_state.dart';

final rootScaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

MethodChannel androidChannel = const MethodChannel('com.presley.jackedlog/android');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for the new dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize database and settings
  Setting setting;
  try {
    final query = db.select(db.settings)..limit(1);
    final settingOrNull = await query.getSingleOrNull();

    if (settingOrNull == null) {
      print('⚠️ Settings table is empty, creating default settings...');
      await db.into(db.settings).insert(defaultSettings);
      final newQuery = db.select(db.settings)..limit(1);
      setting = await newQuery.getSingle();
      print('✓ Default settings created successfully');
    } else {
      setting = settingOrNull;
    }
  } catch (error) {
    return runApp(FailedMigrationsPage(error: error));
  }

  final settingsState = SettingsState(setting);
  runApp(JackedLogApp(settingsState: settingsState));
}

AppDatabase db = AppDatabase();

class JackedLogApp extends StatelessWidget {
  final SettingsState settingsState;

  const JackedLogApp({required this.settingsState, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsState),
        ChangeNotifierProvider(create: (_) => TimerState()),
        ChangeNotifierProvider(create: (_) => PlanState()),
        ChangeNotifierProvider(create: (_) => WorkoutState()),
      ],
      child: MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessenger,
        title: 'JackedLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
