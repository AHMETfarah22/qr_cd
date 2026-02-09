import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../auth/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/backup_service.dart';
import '../../auth/services/statistics_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.process,
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextField(
                controller: currentPasswordController,
                hintText: 'Mevcut Şifre',
                obscureText: true,
                showPasswordToggle: true,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: newPasswordController,
                hintText: 'Yeni Şifre',
                obscureText: true,
                showPasswordToggle: true,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: confirmPasswordController,
                hintText: 'Yeni Şifre (Tekrar)',
                obscureText: true,
                showPasswordToggle: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (newPassword != confirmPassword) {
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yeni şifreler eşleşmiyor'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              final authService = Provider.of<AuthService>(context, listen: false);
              final result = await authService.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
              );

              Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Değiştir',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'Focus Flow uygulamasını keşfet! Odaklanmanı ve verimliliğini artırmana yardımcı olur. 🚀\n\nİndir: https://focusflow.example.com',
      subject: 'Focus Flow - Odaklanma Uygulaması',
    );
  }

  Future<void> _showBackupDialog(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yedekleme için giriş yapmalısınız')),
      );
      return;
    }

    try {
      // 1. Get JSON data
      final jsonString = await BackupService.exportUserData(authService.userEmail!);

      if (jsonString == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yedeklenecek veri bulunamadı')),
          );
        }
        return;
      }

      // 2. Create a temporary file
      final directory = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final fileName = 'focus_flow_backup_$dateStr.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);

      // 3. Share the file
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Focus Flow Yedek Dosyası ($dateStr)',
          subject: 'Focus Flow Yedek',
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yedekleme hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    // 1. Pick file
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        // User canceled the picker
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      if (jsonString.isEmpty) return;

      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.userEmail == null) return;

      // 2. Confirm restoration
      if (!context.mounted) return;
      
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.process,
          title: const Text('Geri Yükleme Onayı', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Seçilen dosyadan veriler geri yüklenecek. Mevcut verilerinizin üzerine yazılacaktır. Devam etmek istiyor musunuz?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm
              child: const Text('Geri Yükle', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      // 3. Process Import
      final importResult = await BackupService.importUserData(jsonString, authService.userEmail!);

      if (!context.mounted) return;

      if (importResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult['message']),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload stats
        await Provider.of<StatisticsService>(context, listen: false).setCurrentUser(authService.userEmail);
        
        // Suggest re-login or restart
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.process,
            title: const Text('Başarılı', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Veriler başarıyla yüklendi. Uygulamanın güncel verilerle çalışabilmesi için yeniden başlatılması önerilir.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  authService.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('Tamam', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult['message']),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya okuma hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
                activeThumbColor: AppColors.accent,
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
            const SizedBox(height: 32),
            _buildSectionTitle('HESAP AYARLARI'),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Şifre Değiştir',
              subtitle: 'Hesap şifrenizi güncelleyin',
              icon: Icons.lock_outline,
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onPressed: () => _showChangePasswordDialog(context),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Not: Şifreniz güvenli bir şekilde saklanır.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('VERİ YÖNETİMİ'),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Verileri Yedekle',
              subtitle: 'Verilerinizi dışa aktarın',
              icon: Icons.cloud_upload_outlined,
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onPressed: () => _showBackupDialog(context),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              title: 'Geri Yükle',
              subtitle: 'Yedekten verileri yükleyin',
              icon: Icons.cloud_download_outlined,
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onPressed: () => _showRestoreDialog(context),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('UYGULAMA'),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Arkadaşlarınla Paylaş',
              subtitle: 'WhatsApp veya diğer uygulamalarla paylaşın',
              icon: Icons.share_outlined,
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onPressed: _shareApp,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Versiyon 1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontSize: 12,
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
        color: AppColors.process.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
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
