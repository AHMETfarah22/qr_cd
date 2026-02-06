import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
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
      statsService.completeSession(totalMinutes);
    }
    _previousState = timerService.state;
  }
  
  @override
  Widget build(BuildContext context) {
    TimerService timerService;
    try {
      timerService = Provider.of<TimerService>(context);
      debugPrint("TimerScreen: Rendering state: ${timerService.state}, time: ${timerService.currentTimeSeconds}");
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
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
      ),
      body: Stack(
        children: [
          Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 140.0,
                    lineWidth: 8.0,
                    percent: timerService.progress.clamp(0.0, 1.0),
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: AppColors.process,
                    progressColor: timerService.state == TimerState.failure 
                        ? AppColors.error 
                        : AppColors.accent,
                    animation: false,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerString,
                        style: TextStyle(
                          fontSize: hours > 0 ? 60 : 80,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        timerService.state == TimerState.idle 
                            ? "HAZIR" 
                            : (timerService.state == TimerState.running ? "KALAN SÜRE" : "HATALI ODAK"),
                        style: TextStyle(
                          color: timerService.state == TimerState.failure 
                              ? AppColors.error 
                              : AppColors.accent,
                          fontSize: 12,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              if (timerService.state == TimerState.idle)
                Column(
                  children: [
                    if (timerService.level == 1)
                      const Text(
                        "30 Saniye Odaklanma Testi",
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Column(
                        children: [
                          Text(
                            "${(timerService.currentTimeSeconds ~/ 3600)} Saat Odaklanma",
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: (timerService.currentTimeSeconds ~/ 60).toDouble().clamp(60.0, 600.0),
                            min: 60,
                            max: 600,
                            divisions: 9, // 1h intervals: 60, 120, 180, 240, 300, 360, 420, 480, 540, 600
                            activeColor: AppColors.accent,
                            inactiveColor: AppColors.process,
                            onChanged: (value) {
                              timerService.setDuration(value.toInt());
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                  ],
                ),

              Text(
                _getStatusMessage(timerService),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 32),
              
              if (timerService.state == TimerState.idle)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        debugPrint("TimerScreen: Start Button Pressed");
                        // Track session start
                        statsService.startSession();
                        timerService.startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      ),
                      child: const Text(
                        "BAŞLAT",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Provider.of<AudioService>(context, listen: false).playAlarm();
                        Future.delayed(const Duration(seconds: 10), () {
                          if (mounted) {
                             Provider.of<AudioService>(context, listen: false).stopAlarm();
                          }
                        });
                      },
                      child: const Text("SESI TEST ET", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  ],
                ),

               if (timerService.state == TimerState.success)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        timerService.resetTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      ),
                      child: const Text(
                        "DEVAM ET",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                ),

               if (timerService.state != TimerState.idle && timerService.state != TimerState.success)
                Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(35),
                        child: InkWell(
                          onTap: () {
                            // Calculate completed duration before cancelling
                            final totalDuration = (timerService.currentTimeSeconds / 60).ceil();
                            final startTime = ((timerService.progress * timerService.currentTimeSeconds) / 60).ceil();
                            final durationCompleted = ((1 - timerService.progress) * (timerService.currentTimeSeconds / (timerService.progress > 0 ? timerService.progress : 1)) / 60).ceil();
                            
                            // Stop alarm sound
                            audioService.stopAlarm();
                            // Track cancelled session
                            statsService.cancelSession(durationCompleted > 0 ? durationCompleted : 1);
                            // Reset timer to idle state
                            timerService.resetTimer();
                          },
                          borderRadius: BorderRadius.circular(35),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF5252),
                                  const Color(0xFFE53935),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "VAZGEÇ", 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Ses durur ve zamanlayıcı sıfırlanır",
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              
               const SizedBox(height: 48),
            ],
          ),
        ),
          ),
          
          // Back button - Top Left (Account)
          Positioned(
            top: 16,
            left: 16,
            child: Tooltip(
              message: 'Hesap Bilgileri',
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.25),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (timerService.state == TimerState.running) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Timer çalışırken hesaba gidemezsiniz!"),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        // Stop any playing alarm sound before navigating back
                        audioService.stopAlarm();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AccountScreen()),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Volume control button - Top Right
          Positioned(
            top: 16,
            right: 16,
            child: Tooltip(
              message: audioService.isMuted ? 'Sesi Aç' : 'Sesi Kapat',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: audioService.isMuted
                        ? [
                            Colors.red.withValues(alpha: 0.9),
                            Colors.red.withValues(alpha: 0.7),
                          ]
                        : [
                            AppColors.process.withValues(alpha: 0.95),
                            AppColors.process.withValues(alpha: 0.75),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: audioService.isMuted 
                        ? Colors.red.withValues(alpha: 0.7) 
                        : AppColors.accent.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: audioService.isMuted 
                          ? Colors.red.withValues(alpha: 0.5)
                          : AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: audioService.isMuted ? 20 : 15,
                      spreadRadius: audioService.isMuted ? 4 : 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      audioService.toggleMute();
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          audioService.isMuted 
                              ? Icons.volume_off_rounded 
                              : Icons.volume_up_rounded,
                          key: ValueKey(audioService.isMuted),
                          color: audioService.isMuted 
                              ? Colors.white 
                              : AppColors.accent,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(TimerService timerService) {
    switch (timerService.state) {
      case TimerState.idle:
        return timerService.level == 1 
            ? "30 saniyelik testi tamamla ve\ngerçek odaklanmaya başla!" 
            : "Süreyi ayarla, Başlat'a bas ve\ntelefonu ters çevir.";
      case TimerState.running:
        return "Derin odaklanma başlıyor...\nTelefonu ters çevir!";
      case TimerState.paused:
        return "Duraklatıldı";
      case TimerState.failure:
        return "ODAK BOZULDU! Telefonu kaldırdın.\nTekrar dene!";
      case TimerState.success:
        return timerService.completedSessions == 1 
            ? "TEBRİKLER! İlk aşamayı geçtin.\nŞimdi 1-10 saat arası odaklanabilirsin."
            : "Tebrikler! Odaklanma tamamlandı.";
    }
  }
}

