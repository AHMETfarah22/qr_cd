import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tscan/features/core/widgets/custom_bottom_nav_bar.dart';
import 'package:tscan/l10n/app_localizations.dart';

Widget _host(Locale locale, int index, ValueChanged<int> onTap) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      bottomNavigationBar: CustomBottomNavBar(currentIndex: index, onTap: onTap),
    ),
  );
}

void main() {
  testWidgets('shows five localized tabs in Turkish', (tester) async {
    await tester.pumpWidget(_host(const Locale('tr'), 0, (_) {}));
    await tester.pumpAndSettle();

    for (final label in ['Anasayfa', 'AI Quest', 'İstatistik', 'Geçmiş', 'Hesap']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('shows English labels and reports tapped tab', (tester) async {
    int? tapped;
    await tester.pumpWidget(_host(const Locale('en'), 0, (i) => tapped = i));
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsOneWidget);
    await tester.tap(find.text('History'));
    expect(tapped, 3);
  });
}
