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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
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
        Provider(create: (_) => SensorService()),
        ChangeNotifierProxyProvider<SettingsService, AudioService>(
          create: (context) => AudioService(context.read<SettingsService>()),
          update: (context, settings, previous) =>
              previous ?? AudioService(settings),
        ),
        ChangeNotifierProxyProvider4<SensorService, AudioService, SettingsService, StatisticsService, TimerService>(
          create: (context) => TimerService(
            context.read<SensorService>(),
            context.read<AudioService>(),
            context.read<SettingsService>(),
          ),
          update: (context, sensor, audio, settings, stats, previous) {
            final service = previous ?? TimerService(sensor, audio, settings);
            // Sync timer service state (level) with persisted statistics
            service.syncWithStats(stats.completedSessions);
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
      home: const LoginScreen(),
    );
  }
}
