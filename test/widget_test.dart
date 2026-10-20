import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medic_app/app/app.dart';
import 'package:medic_app/app/locale_controller.dart';
import 'package:medic_app/core/api/token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const DaktariNowApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the landing page when there is no saved session', (
    tester,
  ) async {
    await _pumpApp(tester, {'locale': 'en'});
    expect(find.text('Find a doctor'), findsOneWidget);
  });

  testWidgets('switches the landing page to Swahili and remembers it', (
    tester,
  ) async {
    await _pumpApp(tester, {'locale': 'en'});
    await tester.tap(find.text('SW').first);
    await tester.pumpAndSettle();

    expect(find.text('Tafuta daktari'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'sw');
  });

  testWidgets('uses the saved language on start', (tester) async {
    await _pumpApp(tester, {'locale': 'sw'});
    expect(find.text('Tafuta daktari'), findsOneWidget);
    expect(Intl.defaultLocale, 'sw');
  });
}
