import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../auth/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/backup_service.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../auth/services/statistics_service.dart';
import '../../auth/screens/login_screen.dart';
import 'package:tscan/l10n/app_localizations.dart';
import '../../../core/services/premium_service.dart';
import '../../premium/screens/paywall_screen.dart';
import '../../pdf_study/services/ai_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final hasKey = await AiService.hasApiKey();
    if (mounted) {
      setState(() => _hasApiKey = hasKey);
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.process,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.key_rounded, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'AI API Anahtarı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.apiKeyDialogBody,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _hasApiKey
                      ? 'Anahtar Kaydedildi (Değiştirmek için yazın)'
                      : 'sk-... / AIza...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (val) {
                  final l10n = AppLocalizations.of(context)!;
                  if (val == null || val.trim().isEmpty) {
                    if (_hasApiKey) return null;
                    return l10n.apiKeyRequired;
                  }
                  if (!AiService.looksLikeApiKey(val)) {
                    return l10n.apiKeyInvalidFormat;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          if (_hasApiKey)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await AiService.clearApiKey();
                await _checkApiKey();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('API anahtarı başarıyla temizlendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Temizle',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (controller.text.trim().isNotEmpty) {
                  await AiService.saveApiKey(controller.text.trim());
                  await _checkApiKey();
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentDeep,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Kaydet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.process,
        title: Text(
          AppLocalizations.of(context)!.changePassword,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextField(
                controller: currentPasswordController,
                hintText: AppLocalizations.of(context)!.password,
                obscureText: true,
                showPasswordToggle: true,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: newPasswordController,
                hintText: AppLocalizations.of(context)!.password,
                obscureText: true,
                showPasswordToggle: true,
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: confirmPasswordController,
                hintText: AppLocalizations.of(context)!.password,
                obscureText: true,
                showPasswordToggle: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppLocalizations.of(context)!.cancelBtn,
              style: const TextStyle(color: AppColors.textSecondary),
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

              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final result = await authService.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: result['success']
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              }
            },
            child: Text(
              AppLocalizations.of(context)!.changePassword,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'TScan uygulamasını keşfet! Odaklanmanı ve verimliliğini artırmana yardımcı olur. 🚀\n\nİndir: https://tscan.example.com',
        subject: 'TScan - Odaklanma Uygulaması',
      ),
    );
  }

  Future<void> _showResetStatisticsDialog(BuildContext context) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.process,
            title: Text(
              AppLocalizations.of(context)!.resetStatistics,
              style: const TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Tüm oturum geçmişi, seri, rozetler ve istatistikler silinecektir. Bu işlem geri alınamaz!\n\nDevam etmek istiyor musunuz?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  AppLocalizations.of(context)!.resetStatistics,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;
    if (!context.mounted) return;

    final statsService = Provider.of<StatisticsService>(context, listen: false);
    await statsService.resetStatistics();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İstatistikler başarıyla sıfırlandı'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
      final jsonString = await BackupService.exportUserData(
        authService.userEmail!,
      );

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
      final fileName = 'tscan_backup_$dateStr.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      // 3. Share the file
      if (context.mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'TScan Yedek Dosyası ($dateStr)',
            subject: 'TScan Yedek',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yedekleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
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

      if (!context.mounted) return;

      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.userEmail == null) return;

      // 2. Confirm restoration
      if (!context.mounted) return;

      bool confirm =
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.process,
              title: const Text(
                'Geri Yükleme Onayı',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Seçilen dosyadan veriler geri yüklenecek. Mevcut verilerinizin üzerine yazılacaktır. Devam etmek istiyor musunuz?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Cancel
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), // Confirm
                  child: const Text(
                    'Geri Yükle',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      // 3. Process Import
      final importResult = await BackupService.importUserData(
        jsonString,
        authService.userEmail!,
      );

      if (!context.mounted) return;

      if (importResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Reload stats
        await Provider.of<StatisticsService>(
          context,
          listen: false,
        ).setCurrentUser(authService.userEmail);

        if (!context.mounted) return;

        // Suggest re-login or restart
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.process,
            title: const Text(
              'Başarılı',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Veriler başarıyla yüklendi. Uygulamanın güncel verilerle çalışabilmesi için yeniden başlatılması önerilir.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  authService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Tamam',
                  style: TextStyle(color: Colors.white),
                ),
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
          SnackBar(
            content: Text('Dosya okuma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final premiumService = Provider.of<PremiumService>(context);

    return AppBackground(
      brightness: Brightness.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.settingsTitle,
            style: const TextStyle(
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
              _buildSectionTitle(
                AppLocalizations.of(context)!.sectionVoiceNotification,
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.alarmSound,
                subtitle: _getAlarmSoundName(
                  settingsService.alarmSound,
                  context,
                ),
                icon: Icons.notifications_active_outlined,
                trailing: DropdownButton<AlarmSound>(
                  value: settingsService.alarmSound,
                  dropdownColor: AppColors.process,
                  underline: Container(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.accent,
                  ),
                  onChanged: (AlarmSound? newValue) {
                    if (newValue != null) {
                      settingsService.setAlarmSound(newValue);
                    }
                  },
                  items: AlarmSound.values.map((AlarmSound sound) {
                    return DropdownMenuItem<AlarmSound>(
                      value: sound,
                      child: Text(
                        _getAlarmSoundName(sound, context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.vibration,
                subtitle: settingsService.vibrationEnabled
                    ? AppLocalizations.of(context)!.on
                    : AppLocalizations.of(context)!.off,
                icon: Icons.vibration,
                trailing: Switch(
                  value: settingsService.vibrationEnabled,
                  onChanged: (value) =>
                      settingsService.setVibrationEnabled(value),
                  activeThumbColor: AppColors.accent,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('USTA ÖZELLİKLERİ'),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: 'TScan Premium',
                subtitle: premiumService.isPremium
                    ? 'Premium Üyelik Aktif ⭐'
                    : 'Usta özelliklerin kilidini aç',
                icon: Icons.stars_rounded,
                trailing: premiumService.isPremium
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaywallScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDeep,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Yükselt',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: 'OpenRouter API Anahtarı',
                subtitle: _hasApiKey ? 'Kaydedildi' : 'Ayarlanmadı',
                icon: Icons.key_rounded,
                trailing: IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: _hasApiKey ? AppColors.accent : Colors.white60,
                  ),
                  onPressed: _showApiKeyDialog,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: 'Sert Odaklanma Modu',
                subtitle: settingsService.isHardMode
                    ? 'Aktif (Seri sıfırlama cezalı)'
                    : 'Pasif',
                icon: Icons.gpp_maybe_rounded,
                trailing: Switch(
                  value: settingsService.isHardMode,
                  onChanged: (value) => settingsService.setHardMode(value),
                  activeThumbColor: AppColors.accent,
                  activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: 'Ortam Sesleri',
                subtitle: _getAmbientSoundName(settingsService.ambientSound),
                icon: Icons.surround_sound_rounded,
                trailing: DropdownButton<AmbientSound>(
                  value: settingsService.ambientSound,
                  dropdownColor: AppColors.process,
                  underline: Container(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.accent,
                  ),
                  onChanged: (AmbientSound? newValue) {
                    if (newValue != null) {
                      settingsService.setAmbientSound(newValue);
                    }
                  },
                  items: AmbientSound.values.map((AmbientSound sound) {
                    return DropdownMenuItem<AmbientSound>(
                      value: sound,
                      child: Text(
                        _getAmbientSoundName(sound),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(
                AppLocalizations.of(context)!.sectionFocusSettings,
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.defaultDuration,
                subtitle: AppLocalizations.of(
                  context,
                )!.mins(settingsService.preferredFocusDurationMinutes),
                icon: Icons.timer_outlined,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        if (settingsService.preferredFocusDurationMinutes > 5) {
                          settingsService.setPreferredFocusDuration(
                            settingsService.preferredFocusDurationMinutes - 5,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        if (settingsService.preferredFocusDurationMinutes <
                            120) {
                          settingsService.setPreferredFocusDuration(
                            settingsService.preferredFocusDurationMinutes + 5,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.dailyGoalSetting,
                subtitle: AppLocalizations.of(
                  context,
                )!.mins(settingsService.dailyFocusGoalMinutes),
                icon: Icons.track_changes_rounded,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        if (settingsService.dailyFocusGoalMinutes > 10) {
                          settingsService.setDailyFocusGoal(
                            settingsService.dailyFocusGoalMinutes - 10,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        if (settingsService.dailyFocusGoalMinutes < 480) {
                          settingsService.setDailyFocusGoal(
                            settingsService.dailyFocusGoalMinutes + 10,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.okumaHizi,
                subtitle: _getReadingSpeedName(
                  settingsService.readingSpeed,
                  AppLocalizations.of(context)!,
                ),
                icon: Icons.speed_rounded,
                trailing:
                    premiumService.canUseFeature(
                      PremiumFeature.personalizedSpeed,
                    )
                    ? DropdownButton<ReadingSpeed>(
                        value: settingsService.readingSpeed,
                        dropdownColor: AppColors.process,
                        underline: Container(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.accent,
                        ),
                        onChanged: (ReadingSpeed? newValue) {
                          if (newValue != null) {
                            settingsService.setReadingSpeed(newValue);
                          }
                        },
                        items: ReadingSpeed.values.map((ReadingSpeed speed) {
                          return DropdownMenuItem<ReadingSpeed>(
                            value: speed,
                            child: Text(
                              _getReadingSpeedName(
                                speed,
                                AppLocalizations.of(context)!,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaywallScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lock_rounded,
                                color: AppColors.accent,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.hizNormal,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(
                AppLocalizations.of(context)!.sectionAccountSettings,
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.changePassword,
                subtitle: AppLocalizations.of(context)!.updatePasswordSubtitle,
                icon: Icons.lock_outline,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  onPressed: () => _showChangePasswordDialog(context),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.passwordSecureNote,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(
                AppLocalizations.of(context)!.sectionDataManagement,
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.backupData,
                subtitle: AppLocalizations.of(context)!.exportDataSubtitle,
                icon: Icons.cloud_upload_outlined,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  onPressed: () => _showBackupDialog(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.restoreData,
                subtitle: AppLocalizations.of(context)!.importDataSubtitle,
                icon: Icons.cloud_download_outlined,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  onPressed: () => _showRestoreDialog(context),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.resetStatistics,
                subtitle: AppLocalizations.of(context)!.resetStatsSubtitle,
                icon: Icons.delete_sweep_outlined,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.red,
                    size: 18,
                  ),
                  onPressed: () => _showResetStatisticsDialog(context),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(
                AppLocalizations.of(context)!.sectionApplication,
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.shareWithFriends,
                subtitle: AppLocalizations.of(context)!.shareSubtitle,
                icon: Icons.share_outlined,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  onPressed: _shareApp,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                title: AppLocalizations.of(context)!.tutorialTitle,
                subtitle: AppLocalizations.of(context)!.tutorialSubtitle,
                icon: Icons.help_outline_rounded,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.version('1.0.0+1'),
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getReadingSpeedName(ReadingSpeed speed, AppLocalizations l10n) {
    switch (speed) {
      case ReadingSpeed.slow:
        return l10n.hizYavas;
      case ReadingSpeed.normal:
        return l10n.hizNormal;
      case ReadingSpeed.fast:
        return l10n.hizHizli;
    }
  }

  String _getAlarmSoundName(AlarmSound sound, BuildContext context) {
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

  String _getAmbientSoundName(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.none:
        return 'Kapalı';
      case AmbientSound.rain:
        return 'Yağmur';
      case AmbientSound.forest:
        return 'Orman';
      case AmbientSound.cafe:
        return 'Kafe';
      case AmbientSound.whiteNoise:
        return 'Beyaz Gürültü';
      case AmbientSound.storm:
        return 'Fırtına';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
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
        color: AppColors.glass,
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
