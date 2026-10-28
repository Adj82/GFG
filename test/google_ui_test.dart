import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gfghub/app/app.dart';
import 'package:gfghub/data/local/local_store.dart';
import 'package:gfghub/data/providers.dart';
import 'package:gfghub/data/seed/seed.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.open();
    await Seed.run(store);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStoreProvider.overrideWithValue(store)],
        child: const SocietyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Member login'));
    await tester.pumpAndSettle();
  }

  Future<void> google(WidgetTester tester, String email) async {
    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, email);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('a non-campus Google account is refused on the sign-in page', (
    tester,
  ) async {
    await boot(tester);
    await google(tester, 'someone@gmail.com');
    // The subtitle and the refusal both say it.
    expect(
      find.textContaining('Use your @kiit.ac.in Google account'),
      findsNWidgets(2),
    );
    expect(find.text('Request to join'), findsNothing);
  });

  testWidgets('a lead signs in with Google and reaches the app', (
    tester,
  ) async {
    await boot(tester);
    await google(tester, '2205211@kiit.ac.in');
    expect(find.text('Sign in'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a first-timer lands on the join form with a fixed email', (
    tester,
  ) async {
    await boot(tester);
    await google(tester, '2599999@kiit.ac.in');
    expect(find.text('Request to join'), findsOneWidget);
    expect(find.text('2599999@kiit.ac.in'), findsOneWidget); // locked email
    expect(find.text('Create a password'), findsNothing); // no password
    expect(tester.takeException(), isNull);
  });
}
