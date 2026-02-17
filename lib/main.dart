import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/settings_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/statistics_service.dart';
import 'features/timer/services/audio_service.dart';
import 'features/timer/services/sensor_service.dart';
import 'features/timer/services/timer_service.dart';
import 'features/timer/screens/timer_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, SettingsService>(
          create: (context) {
            final authService = context.read<AuthService>();
            final settingsService = SettingsService();
            settingsService.setCurrentUser(authService.userEmail);
            return settingsService;
          },
          update: (context, authService, previousSettingsService) {
            final settingsService = previousSettingsService ?? SettingsService();
            settingsService.setCurrentUser(authService.userEmail);
            return settingsService;
          },
        ),
        ChangeNotifierProxyProvider<AuthService, StatisticsService>(
          create: (context) {
            final authService = context.read<AuthService>();
            final statsService = StatisticsService();
            // Set current user when creating the service
            statsService.setCurrentUser(authService.userEmail);
            return statsService;
          },
          update: (context, authService, previousStatsService) {
            // Update statistics service when auth state changes
            final statsService = previousStatsService ?? StatisticsService();
            statsService.setCurrentUser(authService.userEmail);
            return statsService;
          },
        ),
        Provider(
          create: (_) => SensorService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProxyProvider<SettingsService, AudioService>(
          create: (context) => AudioService(context.read<SettingsService>()),
          update: (context, settings, previous) =>
              previous ?? AudioService(settings),
        ),
        ChangeNotifierProxyProvider5<SensorService, AudioService, SettingsService, StatisticsService, NotificationService, TimerService>(
          create: (context) => TimerService(
            context.read<SensorService>(),
            context.read<AudioService>(),
            context.read<SettingsService>(),
            context.read<NotificationService>(),
          ),
          update: (context, sensor, audio, settings, stats, notification, previous) {
            final service = previous ?? TimerService(sensor, audio, settings, notification);
            // Sync timer service state (level) with persisted statistics
            service.updateDependencies(stats);
            return service;
          },
        ),
      ],
      child: const FocusFlowApp(),
    ),
  );
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          // Auto-login: if user was previously logged in, go directly to TimerScreen
          if (authService.isLoggedIn) {
            return const TimerScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
