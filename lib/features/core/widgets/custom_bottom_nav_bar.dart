import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/palette.dart';
import '../../../l10n/app_localizations.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// Floating pill-shaped bottom navigation bar used by MainScreen.
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
    final p = Palette.of(context);
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _NavItem(Icons.timer_outlined, Icons.timer_rounded, l10n.navHome),
      _NavItem(
        Icons.psychology_outlined,
        Icons.psychology_rounded,
        l10n.navAiQuest,
      ),
      _NavItem(Icons.insights_outlined, Icons.insights_rounded, l10n.navStats),
      _NavItem(Icons.history_outlined, Icons.history_rounded, l10n.navHistory),
      _NavItem(
        Icons.person_outline_rounded,
        Icons.person_rounded,
        l10n.navAccount,
      ),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: p.isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0x1F0B5D36),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(child: _buildTab(p, i, items[i])),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(Palette p, int index, _NavItem item) {
    final isActive = currentIndex == index;
    final activeColor = p.accentText;
    final inactiveColor = p.textSecondary.withValues(alpha: 0.8);

    return Semantics(
      selected: isActive,
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: () {
          if (!isActive) HapticFeedback.selectionClick();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent.withValues(alpha: p.isDark ? 0.16 : 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 22,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 260),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
