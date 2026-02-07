import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/statistics_service.dart';
import '../../settings/screens/settings_screen.dart';
import 'login_screen.dart';
import 'session_history_screen.dart';
import 'statistics_chart_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'HESAP BİLGİLERİ',
          style: TextStyle(
            fontSize: 14, // Slightly smaller
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.accent, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.accent, size: 24),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Profile Section (New Design)
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.process.withValues(alpha: 0.5),
                      child: Text(
                        authService.userName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authService.userName ?? 'Kullanıcı',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.process.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      authService.userEmail ?? 'email@example.com',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Statistics Section Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ODAKLANMA ÖZETİ',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Consumer<StatisticsService>(
              builder: (context, statsService, _) {
                return Column(
                  children: [
                    // Streak Card (Prominent)
                    _buildStreakCard(statsService, context),
                    
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.play_circle_outline,
                            title: 'Toplam',
                            value: '${statsService.totalSessions}',
                            subtitle: 'Oturum',
                            color: Colors.blue.shade300,
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle_outline,
                            title: 'Başarılı',
                            value: '${statsService.completedSessions}',
                            subtitle: 'Oturum',
                            color: Colors.green.shade300,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.cancel_outlined,
                            title: 'Vazgeçilen',
                            value: '${statsService.cancelledSessions}',
                            subtitle: 'Oturum',
                            color: Colors.red.shade300,
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.access_time_rounded,
                            title: 'Toplam Süre',
                            value: statsService.totalTimeFormatted,
                            subtitle: '',
                            color: Colors.orange.shade300,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Badges Section
                    if (statsService.badges.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'KAZANILAN ROZETLER',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: statsService.badges.length,
                        itemBuilder: (context, index) {
                          return _buildBadgeItem(statsService.badges[index]);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'BAŞARI ANALİZİ',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Success Rate
                    _buildSuccessRateCard(statsService, context),
                    
                    const SizedBox(height: 24),
                    
                    // Session History Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.process.withValues(alpha: 0.6),
                            AppColors.process.withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SessionHistoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, color: AppColors.accent),
                            SizedBox(width: 12),
                            Text(
                              'OTURUM GEÇMİŞİ',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Charts Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.25),
                    Colors.blue.withValues(alpha: 0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsChartScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, color: Colors.purple.shade200),
                    const SizedBox(width: 12),
                    Text(
                      'DETAYLI GRAFİKLER',
                      style: TextStyle(
                        color: Colors.purple.shade200,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),

            // Logout & Delete Buttons
            _buildActionButtons(context, authService),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Extracted Action Buttons to clean up build method
  Widget _buildActionButtons(BuildContext context, AuthService authService) {
    return Column(
      children: [
        // Logout Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.process.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: ElevatedButton(
            onPressed: () => _confirmLogout(context, authService),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text(
                  'ÇIKIŞ YAP',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Delete Account Button
        TextButton(
          onPressed: () => _confirmDeleteAccount(context, authService),
          child: Text(
            'Hesabı Sil',
            style: TextStyle(
              color: Colors.red.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.process,
        title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Çıkış yapmak istediğinizden emin misiniz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, AuthService authService) async {
    // Similar to logout but for delete
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.process,
        title: const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SİL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authService.deleteAccount();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard(StatisticsService statsService, BuildContext context) {
    // Safely calculate success rate
    final double successRate = statsService.totalSessions > 0 
        ? (statsService.completedSessions / statsService.totalSessions * 100) 
        : 0.0;
        
    final color = successRate >= 70 ? Colors.green : (successRate >= 40 ? Colors.orange : Colors.red);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Başarı Oranı',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${successRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: successRate / 100,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(StatisticsService stats, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GÜNLÜK SERİ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stats.currentStreak} GÜN!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String badgeName) {
    IconData icon;
    Color color;

    switch (badgeName) {
      case 'Erkenci Kuş':
        icon = Icons.wb_sunny_rounded;
        color = Colors.amber;
        break;
      case 'Maratoncu':
        icon = Icons.timer_rounded;
        color = Colors.blueAccent;
        break;
      case 'Usta Odaklanıcı':
        icon = Icons.workspace_premium_rounded;
        color = Colors.purpleAccent;
        break;
      default:
        icon = Icons.military_tech_rounded;
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.process.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            badgeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
