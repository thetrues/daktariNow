import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medic_app/app/app.dart';
import 'package:medic_app/core/api/token_store.dart';

void main() {
  testWidgets('shows onboarding when there is no saved session', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [tokenStoreProvider.overrideWithValue(MemoryTokenStore())],
      child: const DaktariNowApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
  });
}
