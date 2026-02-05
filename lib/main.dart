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
        ChangeNotifierProvider(create: (_) => StatisticsService()),
        Provider(create: (_) => SensorService()),
        ChangeNotifierProxyProvider<SettingsService, AudioService>(
          create: (context) => AudioService(context.read<SettingsService>()),
          update: (context, settings, previous) =>
              previous ?? AudioService(settings),
        ),
        ChangeNotifierProxyProvider3<SensorService, AudioService, SettingsService, TimerService>(
          create: (context) => TimerService(
            context.read<SensorService>(),
            context.read<AudioService>(),
            context.read<SettingsService>(),
          ),
          update: (context, sensor, audio, settings, previous) =>
              previous ?? TimerService(sensor, audio, settings),
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
