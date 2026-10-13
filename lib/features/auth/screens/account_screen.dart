import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/premium_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../l10n/app_localizations.dart';
import '../../premium/screens/paywall_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../services/auth_service.dart';
import '../services/statistics_service.dart';
import 'login_screen.dart';

/// Account tab: who you are, today's progress, badges, and the few things
/// you manage here (Premium, settings, sign-out). Detailed numbers live in
/// the Stats and History tabs.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final stats = Provider.of<StatisticsService>(context);
    final premium = Provider.of<PremiumService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _buildProfileHeader(context, authService, premium, l10n),
            const SizedBox(height: 22),
            _buildTodayCard(context, stats, l10n),
            if (stats.badges.isNotEmpty) ...[
              SectionLabel(l10n.earnedBadges),
              _buildBadges(stats.badges, l10n),
            ],
            SectionLabel(l10n.accountSection),
            GlassGroup(
              children: [
                GlassTile(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: Colors.amber,
                  title: l10n.paywallTitle,
                  subtitle: _premiumSubtitle(context, premium, l10n),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
                GlassTile(
                  icon: Icons.settings_rounded,
                  title: l10n.menuSettings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlassGroup(
              children: [
                GlassTile(
                  icon: Icons.logout_rounded,
                  iconColor: Colors.white,
                  title: l10n.menuLogout,
                  trailing: const SizedBox.shrink(),
                  onTap: () => _confirmLogout(context, authService, l10n),
                ),
                GlassTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: Colors.redAccent,
                  title: l10n.deleteAccount,
                  titleColor: Colors.redAccent,
                  trailing: const SizedBox.shrink(),
                  onTap: () =>
                      _confirmDeleteAccount(context, authService, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _premiumSubtitle(
    BuildContext context,
    PremiumService premium,
    AppLocalizations l10n,
  ) {
    if (premium.isPremium) {
      final expiry = premium.expiry;
      if (expiry == null) return l10n.premiumActivatedTitle;
      final locale = Localizations.localeOf(context).toString();
      return l10n.premiumActiveUntil(DateFormat.yMMMd(locale).format(expiry));
    }
    return premium.canUploadPdf
        ? '${l10n.freePlan} · ${l10n.freePdfRemaining(premium.freePdfRemaining)}'
        : '${l10n.freePlan} · ${l10n.freeLimitReachedTitle}';
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AuthService authService,
    PremiumService premium,
    AppLocalizations l10n,
  ) {
    final name = authService.userName ?? l10n.user;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: premium.isPremium
                      ? [Colors.amber, const Color(0xFFF6D277)]
                      : [AppColors.accent, AppColors.accentDeep],
                ),
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.process,
                backgroundImage: authService.userImagePath != null
                    ? FileImage(File(authService.userImagePath!))
                    : null,
                child: authService.userImagePath == null
                    ? Text(
                        name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            GestureDetector(
              onTap: () => _pickImage(context, authService),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.accentDeep,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (premium.isPremium) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          authService.userEmail ?? '',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// Today at a glance: streak on the left, daily goal on the right.
  Widget _buildTodayCard(
    BuildContext context,
    StatisticsService stats,
    AppLocalizations l10n,
  ) {
    final settings = Provider.of<SettingsService>(context);
    final goal = settings.dailyFocusGoalMinutes;
    final minutes = stats.dailyFocusMinutes;
    final progress = goal == 0 ? 0.0 : (minutes / goal).clamp(0.0, 1.0);
    final reached = minutes >= goal;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.deepOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.currentStreak}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.streakDays(stats.currentStreak),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 24,
              thickness: 1,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      color: reached ? Colors.tealAccent : AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$minutes/$goal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          reached
                              ? l10n.goalReachedShort
                              : l10n.minutesLeft(goal - minutes),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(List<String> badges, AppLocalizations l10n) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, icon, color) = _badgeInfo(badges[index], l10n);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  (String, IconData, Color) _badgeInfo(String badge, AppLocalizations l10n) {
    final tr = l10n.localeName == 'tr';
    return switch (badge) {
      'Erkenci Kuş' => (
        l10n.badgeEarlyBird,
        Icons.wb_sunny_rounded,
        Colors.amber,
      ),
      'Maratoncu' => (
        l10n.badgeMarathoner,
        Icons.timer_rounded,
        Colors.lightBlueAccent,
      ),
      'Usta Odaklanıcı' => (
        l10n.badgeMaster,
        Icons.workspace_premium_rounded,
        Colors.purpleAccent,
      ),
      'Akademisyen' => (
        tr ? 'Akademisyen' : 'Scholar',
        Icons.school_rounded,
        Colors.deepPurpleAccent,
      ),
      'Dahi' => (
        tr ? 'Dahi' : 'Genius',
        Icons.psychology_rounded,
        Colors.pinkAccent,
      ),
      'Bilgin' => (
        tr ? 'Bilgin' : 'Sage',
        Icons.auto_stories_rounded,
        Colors.tealAccent,
      ),
      _ => (badge, Icons.military_tech_rounded, Colors.grey),
    };
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AuthService authService,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.process,
        title: Text(
          l10n.menuLogout,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelBtn),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.menuLogout),
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

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AuthService authService,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.process,
        title: Text(
          l10n.deleteAccount,
          style: const TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          l10n.deleteAccountConfirm,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelBtn),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Future<void> _pickImage(BuildContext context, AuthService authService) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/${pickedFile.name}');
      authService.updateProfileImage(savedImage.path);
    }
  }
}
