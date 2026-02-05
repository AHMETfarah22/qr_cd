import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'AYARLAR',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('SES VE BİLDİRİM'),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Alarm Sesi',
              subtitle: _getAlarmSoundName(settingsService.alarmSound),
              icon: Icons.notifications_active_outlined,
              trailing: DropdownButton<AlarmSound>(
                value: settingsService.alarmSound,
                dropdownColor: AppColors.process,
                underline: Container(),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.accent),
                onChanged: (AlarmSound? newValue) {
                  if (newValue != null) {
                    settingsService.setAlarmSound(newValue);
                  }
                },
                items: AlarmSound.values.map((AlarmSound sound) {
                  return DropdownMenuItem<AlarmSound>(
                    value: sound,
                    child: Text(
                      _getAlarmSoundName(sound),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              title: 'Titreşim',
              subtitle: settingsService.vibrationEnabled ? 'Açık' : 'Kapalı',
              icon: Icons.vibration,
              trailing: Switch(
                value: settingsService.vibrationEnabled,
                onChanged: (value) => settingsService.setVibrationEnabled(value),
                activeColor: AppColors.accent,
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('ODAKLANMA AYARLARI'),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Varsayılan Süre',
              subtitle: '${settingsService.preferredFocusDurationMinutes} dakika',
              icon: Icons.timer_outlined,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
                    onPressed: () {
                      if (settingsService.preferredFocusDurationMinutes > 5) {
                        settingsService.setPreferredFocusDuration(
                            settingsService.preferredFocusDurationMinutes - 5);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                    onPressed: () {
                      if (settingsService.preferredFocusDurationMinutes < 120) {
                        settingsService.setPreferredFocusDuration(
                            settingsService.preferredFocusDurationMinutes + 5);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Not: Belirlediğiniz süre, sonraki oturumlarınızda varsayılan olarak kullanılacaktır.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAlarmSoundName(AlarmSound sound) {
    switch (sound) {
      case AlarmSound.bird:
        return 'Kuş Sesi';
      case AlarmSound.siren:
        return 'Siren';
      case AlarmSound.zen:
        return 'Zen Çanı';
      case AlarmSound.digital:
        return 'Dijital';
      case AlarmSound.nature:
        return 'Doğa Sesleri';
      case AlarmSound.silent:
        return 'Sessiz';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.process.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
