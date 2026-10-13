import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.process : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.accent.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              _buildTab(
                context: context,
                index: 0,
                icon: Icons.home_rounded,
                activeIcon: Icons.home_rounded,
                label: l10n.navHome,
                isDark: isDark,
              ),
              _buildTab(
                context: context,
                index: 1,
                icon: Icons.psychology_outlined,
                activeIcon: Icons.psychology_rounded,
                label: l10n.navAiQuest,
                isDark: isDark,
              ),
              _buildTab(
                context: context,
                index: 2,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: l10n.navAccount,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isActive = currentIndex == index;
    final activeColor = AppColors.accent;
    final inactiveColor = isDark
        ? AppColors.textSecondary.withValues(alpha: 0.6)
        : Colors.black54;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with glow effect when active
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                  letterSpacing: isActive ? 0.5 : 0,
                ),
                child: Text(label),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 3,
                width: isActive ? 32 : 0,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
