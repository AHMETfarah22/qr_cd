import 'package:flutter/material.dart';
import '../theme/palette.dart';

/// Small design system for calm, uncluttered screens: related items share
/// one frosted [GlassGroup] separated by hairlines instead of each getting
/// its own card, and sections are introduced by a quiet [SectionLabel].

/// A frosted glass surface.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: Palette.of(context).cardDecoration(radius: radius),
      child: child,
    );
  }
}

/// Quiet uppercase label above a section.
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 22, 6, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Several rows in one glass card, separated by hairlines.
class GlassGroup extends StatelessWidget {
  final List<Widget> children;

  const GlassGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        );
      }
      rows.add(children[i]);
    }
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: rows),
      ),
    );
  }
}

/// A list row: tinted icon, title, optional subtitle and trailing widget.
/// Shows a chevron when tappable and no trailing widget is given.
class GlassTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const GlassTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = const Color(0xFF43F47F),
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor ?? Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
