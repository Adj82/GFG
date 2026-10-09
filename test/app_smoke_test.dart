import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gfghub/app/app.dart';
import 'package:gfghub/app/router.dart';
import 'package:gfghub/data/local/local_store.dart';
import 'package:gfghub/data/providers.dart';
import 'package:gfghub/data/seed/seed.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(rootBundle.load('assets/fonts/$f'));
    }
    await l.load();
  }

  await load('Bricolage', [
    'BricolageGrotesque-600.ttf',
    'BricolageGrotesque-700.ttf',
    'BricolageGrotesque-800.ttf',
  ]);
  await load('Figtree', [
    'Figtree-400.ttf',
    'Figtree-500.ttf',
    'Figtree-600.ttf',
    'Figtree-700.ttf',
    'Figtree-800.ttf',
  ]);
}

void main() {
  Future<ProviderContainer> boot(
    WidgetTester tester,
    String email,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _loadFonts();
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
    // Signed-out visitors land on the public home; members use the login button.
    await tester.tap(find.text('Member login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), Seed.password);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Future<void> visit(
    WidgetTester tester,
    ProviderContainer c,
    String path,
  ) async {
    c.read(routerProvider).go(path);
    await tester.pumpAndSettle();
    final err = tester.takeException();
    expect(err, isNull, reason: 'Route $path threw: $err');
  }

  for (final (who, email) in [
    ('President', '2105101@kiit.ac.in'),
    ('Member', '2305318@kiit.ac.in'),
    ('App Dev Lead', '2205211@kiit.ac.in'),
  ]) {
    for (final size in [const Size(430, 932), const Size(1280, 900)]) {
      testWidgets('$who walks every screen at ${size.width.toInt()}px', (
        tester,
      ) async {
        final c = await boot(tester, email, size);
        for (final path in [
          '/home',
          '/tasks',
          '/events',
          '/funds',
          '/more',
          '/funds/approvals',
          '/announcements',
          '/meetings',
          '/people',
          '/people/requests',
          '/vault',
          '/analytics',
          '/settings',
          '/audit',
          '/handover',
          '/inbox',
          '/search',
          '/profile',
          '/profile/edit',
        ]) {
          await visit(tester, c, path);
        }
        final t = c.read(tasksProvider);
        final ev = c.read(eventsProvider);
        final ex = c.read(expensesProvider);
        final mt = c.read(meetingsProvider);
        final ap = c.read(applicationsProvider);
        for (final x in t.take(12)) {
          await visit(tester, c, '/tasks/${x.id}');
        }
        for (final e in ev) {
          await visit(tester, c, '/events/${e.id}');
        }
        if (ev.isNotEmpty) {
          await visit(tester, c, '/events/${ev.first.id}/check-in');
        }
        for (final e in ex) {
          await visit(tester, c, '/funds/expense/${e.id}');
        }
        if (mt.isNotEmpty) await visit(tester, c, '/meetings/${mt.first.id}');
        if (ap.isNotEmpty) {
          await visit(tester, c, '/people/requests/${ap.first.id}');
        }
        await visit(
          tester,
          c,
          '/people/${c.read(activeMembersProvider).first.id}',
        );
      });
    }
  }
}
