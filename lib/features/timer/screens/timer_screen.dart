import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/session_category.dart';
import '../../auth/screens/account_screen.dart';
import '../../auth/services/statistics_service.dart';
import '../services/timer_service.dart';
import '../services/audio_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  TimerState? _previousState;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final timerService = Provider.of<TimerService>(context, listen: false);
    final statsService = Provider.of<StatisticsService>(context, listen: false);
    
    // Track state changes to detect completion
    if (_previousState != null && _previousState != TimerState.success && timerService.state == TimerState.success) {
      // Timer just completed successfully
      final durationMinutes = ((timerService.currentTimeSeconds / 60).ceil());
      final totalMinutes = timerService.level == 1 ? 1 : 60; // Level 1 is 30 seconds (round to 1 min), Level 2+ is 60 minutes
      statsService.completeSession(totalMinutes, category: timerService.currentCategory);
    }
    _previousState = timerService.state;
  }
  
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
    final statsService = Provider.of<StatisticsService>(context, listen: false);
    
    return Scaffold(
      backgroundColor: timerService.state == TimerState.failure 
          ? AppColors.error.withValues(alpha: 0.1)
          : AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "ODAKLANMA SAYACI",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            if (timerService.level > 1)
              Text(
                "SEVİYE ${timerService.level}",
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
              tooltip: 'Hesap Bilgileri',
              onPressed: () {
                if (timerService.state == TimerState.running) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Timer çalışırken hesaba gidemezsiniz!"),
                      duration: Duration(seconds: 2),
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
                        child: Text(
                          timerService.state == TimerState.idle 
                              ? "HAZIR" 
                              : (timerService.state == TimerState.running ? "ODAKLAN" : "HATALI"),
                          style: TextStyle(
                            color: timerService.state == TimerState.failure 
                                ? AppColors.error 
                                : AppColors.accent,
                            fontSize: 12,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
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
                      const Text(
                        "30 Saniye Odaklanma Testi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Başlangıç Seviyesi",
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
                        "${(timerService.currentTimeSeconds ~/ 3600)} Saat Odaklanma",
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: (timerService.currentTimeSeconds ~/ 60).toDouble().clamp(60.0, 600.0),
                        min: 60,
                        max: 600,
                        divisions: 9,
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
                const Text(
                  'KATEGORİ SEÇ',
                  style: TextStyle(
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
                              category.displayName,
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
                    child: const Text(
                      "BAŞLAT",
                      style: TextStyle(
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
                    ElevatedButton(
                      onPressed: () {
                        timerService.resetTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.process,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "DEVAM ET",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0),
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
                            final durationCompleted = ((1 - timerService.progress) * (timerService.currentTimeSeconds / (timerService.progress > 0 ? timerService.progress : 1)) / 60).ceil();
                            
                            audioService.stopAlarm();
                            statsService.cancelSession(durationCompleted > 0 ? durationCompleted : 1, category: timerService.currentCategory);
                            timerService.resetTimer();
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
                                const Text(
                                  "VAZGEÇ", 
                                  style: TextStyle(
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
                  _getStatusMessage(timerService),
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

  String _getStatusMessage(TimerService timerService) {
    switch (timerService.state) {
      case TimerState.idle:
        return timerService.level == 1 
            ? "30 saniyelik testi tamamla ve\ngerçek odaklanmaya başla!" 
            : "Süreyi ayarla, kategori seç ve odaklan!";
      case TimerState.running:
        return "Derin odaklanma başlıyor...\nTelefonu ters çevir!";
      case TimerState.paused:
        return "Duraklatıldı";
      case TimerState.failure:
        return "ODAK BOZULDU!\nTelefonu kaldırdın.";
      case TimerState.success:
        return timerService.completedSessions == 1 
            ? "TEBRİKLER! İlk aşama tamam.\n1 saatlik odaklanma açıldı!"
            : "Tebrikler! Oturum tamamlandı.";
    }
  }
}
