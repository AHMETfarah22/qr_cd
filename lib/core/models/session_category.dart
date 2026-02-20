import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

enum SessionCategory {
  work,
  study,
  reading,
  meditation,
  exercise,
  creative,
  breakTime,
  other,
}

extension SessionCategoryExtension on SessionCategory {
  String get localizedName {
    // This will be replaced by actual localization call in the UI
    return displayName;
  }

  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return displayName;
    
    switch (this) {
      case SessionCategory.work:
        return l10n.catWork;
      case SessionCategory.study:
        return l10n.catStudy;
      case SessionCategory.reading:
        return l10n.catReading;
      case SessionCategory.meditation:
        return l10n.catMeditation;
      case SessionCategory.exercise:
        return l10n.catExercise;
      case SessionCategory.creative:
        return l10n.catCreative;
      case SessionCategory.breakTime:
        return l10n.catBreak;
      case SessionCategory.other:
        return l10n.catOther;
    }
  }

  String get displayName {
    switch (this) {
      case SessionCategory.work:
        return 'Çalışma';
      case SessionCategory.study:
        return 'Ders Çalışma';
      case SessionCategory.reading:
        return 'Okuma';
      case SessionCategory.meditation:
        return 'Meditasyon';
      case SessionCategory.exercise:
        return 'Egzersiz';
      case SessionCategory.creative:
        return 'Yaratıcı İş';
      case SessionCategory.breakTime:
        return 'Mola';
      case SessionCategory.other:
        return 'Diğer';
    }
  }

  IconData get icon {
    switch (this) {
      case SessionCategory.work:
        return Icons.work_outline;
      case SessionCategory.study:
        return Icons.school_outlined;
      case SessionCategory.reading:
        return Icons.menu_book_outlined;
      case SessionCategory.meditation:
        return Icons.self_improvement_outlined;
      case SessionCategory.exercise:
        return Icons.fitness_center_outlined;
      case SessionCategory.creative:
        return Icons.palette_outlined;
      case SessionCategory.breakTime:
        return Icons.coffee_outlined;
      case SessionCategory.other:
        return Icons.more_horiz_outlined;
    }
  }

  Color get color {
    switch (this) {
      case SessionCategory.work:
        return Colors.blue;
      case SessionCategory.study:
        return Colors.purple;
      case SessionCategory.reading:
        return Colors.orange;
      case SessionCategory.meditation:
        return Colors.green;
      case SessionCategory.exercise:
        return Colors.red;
      case SessionCategory.creative:
        return Colors.pink;
      case SessionCategory.breakTime:
        return Colors.teal;
      case SessionCategory.other:
        return AppColors.textSecondary;
    }
  }

  // Helper to convert string to enum
  static SessionCategory fromString(String value) {
    return SessionCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionCategory.other,
    );
  }
}
