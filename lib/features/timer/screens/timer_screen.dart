
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../../auth/screens/account_screen.dart';

import '../services/timer_service.dart';
import '../services/audio_service.dart';
import '../../../l10n/app_localizations.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {

  
  @override
  Widget build(BuildContext context) {
    TimerService timerService;
    try {
      timerService = Provider.of<TimerService>(context);
    } catch (e) {
      return const Scaffold(body: Center(child: Text("Error: TimerService not found")));
    }
    
    int totalSeconds = timerService.currentTimeSeconds;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String timerString;
    if (hours > 0) {
      timerString = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      timerString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    final audioService = Provider.of<AudioService>(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Update TimerService with localized notification strings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timerService.updateLocalization({
        'successTitle': l10n.notifSuccessTitle,
        'successBody': l10n.notifSuccessBody,
        'breakEndTitle': l10n.notifBreakEndTitle,
        'breakEndBody': l10n.notifBreakEndBody,
      });
    });
    
    return Scaffold(
      backgroundColor: timerService.state == TimerState.failure 
          ? AppColors.error.withValues(alpha: 0.1)
          : AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              l10n.focusTimer,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            if (timerService.level > 1)
              Text(
                l10n.level(timerService.level),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        
        // Profile Button (Left)
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.process.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_rounded, size: 20, color: AppColors.accent),
              tooltip: l10n.accountInfo,
              onPressed: () {
                if (timerService.state == TimerState.running) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.cannotGoToAccount),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  audioService.stopAlarm();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccountScreen()),
                  );
                }
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // Main Timer Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 130.0,
                    lineWidth: 8.0,
                    percent: timerService.progress.clamp(0.0, 1.0),
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: AppColors.process.withValues(alpha: 0.1),
                    progressColor: timerService.state == TimerState.failure 
                        ? AppColors.error 
                        : AppColors.accent,
                    animation: false,
                    widgetIndicator: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.circle, 
                        size: 14, 
                        color: timerService.state == TimerState.failure 
                            ? AppColors.error 
                            : AppColors.accent,
                      ),
                    ),
                  ),
                  
                  // Inner Glow Effect
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (timerService.state == TimerState.failure 
                              ? AppColors.error 
                              : AppColors.accent).withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                  // Timer Text & Status
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerString,
                        style: TextStyle(
                          fontSize: hours > 0 ? 56 : 72,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          shadows: [
                            Shadow(
                              color: (timerService.state == TimerState.failure 
                                  ? AppColors.error 
                                  : AppColors.accent).withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (timerService.state == TimerState.failure 
                              ? AppColors.error 
                              : AppColors.accent).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (timerService.state == TimerState.failure 
                                ? AppColors.error 
                                : AppColors.accent).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Builder(
                          builder: (context) {
                            String statusText;
                            Color statusColor;
                            
                            switch (timerService.state) {
                              case TimerState.idle:
                                statusText = l10n.ready;
                                statusColor = AppColors.accent;
                                break;
                              case TimerState.running:
                                statusText = l10n.focus;
                                statusColor = AppColors.accent;
                                break;
                              case TimerState.paused:
                                statusText = l10n.paused;
                                statusColor = Colors.orange;
                                break;
                              case TimerState.failure:
                                statusText = l10n.failed;
                                statusColor = AppColors.error;
                                break;
                              case TimerState.success:
                                statusText = l10n.success;
                                statusColor = Colors.green;
                                break;
                              case TimerState.breakTime:
                                statusText = l10n.breakLabel;
                                statusColor = Colors.blue;
                                break;
                            }
                            
                            return Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Conditional UI based on state
              if (timerService.state == TimerState.idle) ...[
                if (timerService.level == 1)
                  Column(
                    children: [
                      Text(
                        l10n.secondsFocusTest,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.beginnerLevel,
                        style: TextStyle(
                          color: AppColors.accent.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        l10n.minuteFocus(timerService.totalTimeSeconds ~/ 60),
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: (timerService.totalTimeSeconds ~/ 60).toDouble().clamp(5.0, 120.0),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        activeColor: AppColors.accent,
                        inactiveColor: AppColors.process,
                        onChanged: (value) {
                          timerService.setDuration(value.toInt());
                        },
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),
                
                // Category Selector
                Text(
                  l10n.selectCategory,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: SessionCategory.values.map((category) {
                    final isSelected = timerService.currentCategory == category;
                    return GestureDetector(
                      onTap: () => timerService.setCategory(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? category.color.withValues(alpha: 0.2)
                              : AppColors.process.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                                ? category.color
                                : AppColors.process.withValues(alpha: 0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ] : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 14,
                              color: isSelected ? category.color : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.getDisplayName(context),
                              style: TextStyle(
                                color: isSelected ? category.color : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Action Buttons - Moved HIGHER up
              if (timerService.state == TimerState.idle)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      timerService.startTimer();
                      audioService.playStartSound(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.start,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),



              if (timerService.state == TimerState.success)
                Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.accent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.breakTimeTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            timerService.startBreak(15);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.process.withValues(alpha: 0.3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                            ),
                          ),
                          child: Text(l10n.minBreak(15)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            timerService.startBreak(30);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.process.withValues(alpha: 0.3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                            ),
                          ),
                          child: Text(l10n.minBreak(30)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        timerService.resetTimer();
                      },
                      child: Text(
                        l10n.dontTakeBreak,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),

               if (timerService.state != TimerState.idle && timerService.state != TimerState.success)
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Always stop alarm first when user interacts
                            audioService.stopAlarm();

                            if (timerService.state == TimerState.breakTime) {
                               timerService.resetTimer();
                            } else {
                               // Calculate elapsed minutes
                               final elapsedSeconds = timerService.totalTimeSeconds - timerService.currentTimeSeconds;
                               final durationCompleted = (elapsedSeconds / 60).ceil();
                               timerService.cancelTimer(durationCompleted > 0 ? durationCompleted : 1);
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF5252),
                                  const Color(0xFFE53935),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  timerService.state == TimerState.breakTime ? l10n.endBreak : l10n.cancel, 
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
              
              // Status Message (Moved to Bottom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _getStatusMessage(timerService, l10n),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(TimerService timerService, AppLocalizations l10n) {
    switch (timerService.state) {
      case TimerState.idle:
        return timerService.level == 1 
            ? l10n.statusIdleLvl1 
            : l10n.statusIdle;
      case TimerState.running:
        return l10n.statusRunning;
      case TimerState.paused:
        return l10n.statusPaused;
      case TimerState.failure:
        return l10n.statusFailure;
      case TimerState.success:
        return timerService.completedSessions == 1 
            ? l10n.statusSuccessFirst
            : l10n.statusSuccess;
      case TimerState.breakTime:
        return l10n.statusBreak;
    }
  }
}
