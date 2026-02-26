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
import 'features/onboarding/screens/onboarding_screen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'core/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
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
      child: const TScanApp(),
    ),
  );
}

class TScanApp extends StatelessWidget {
  const TScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, _) {
        return MaterialApp(
          title: 'TScan',
          debugShowCheckedModeBanner: false,
          theme: settingsService.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
          ],
          home: Consumer<AuthService>(
            builder: (context, authService, _) {
              // Auto-login logic
              if (authService.isLoggedIn) {
                // If logged in, check if onboarding is complete
                if (!settingsService.isOnboardingCompleted) {
                  return const OnboardingScreen();
                }
                return const TimerScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
