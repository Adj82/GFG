import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gfghub/app/app.dart';
import 'package:gfghub/app/router.dart';
import 'package:gfghub/data/local/local_store.dart';
import 'package:gfghub/data/models/models.dart';
import 'package:gfghub/data/providers.dart';
import 'package:gfghub/data/seed/seed.dart';
import 'package:gfghub/domain/actions/guest_actions.dart';
import 'package:gfghub/domain/actions/people_actions.dart';
import 'package:gfghub/domain/registration_rules.dart';
import 'package:gfghub/domain/snake_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

SocietyEvent _event({
  int? capacity,
  List<String> rsvps = const [],
  bool isPublic = true,
  bool cancelled = false,
  Duration start = const Duration(days: 2),
}) {
  final at = DateTime.now().add(start);
  return SocietyEvent(
    id: 'e1',
    title: 'Test',
    type: EventType.workshop,
    startsAt: at,
    endsAt: at.add(const Duration(hours: 2)),
    venue: 'Hall',
    createdBy: 'u',
    createdAt: DateTime.now(),
    checkInSecret: 's',
    capacity: capacity,
    rsvpIds: rsvps,
    isPublic: isPublic,
    cancelled: cancelled,
  );
}

SnakeEngine _running() {
  final e = SnakeEngine()..start();
  return e;
}

void main() {
  group('snake', () {
    test('every word fits the board and sits inside it', () {
      for (final w in SnakeEngine.words) {
        expect(
          Glyphs.widthOf(w),
          lessThanOrEqualTo(SnakeEngine.cols),
          reason: w,
        );
        final cells = Glyphs.layout(
          w,
          cols: SnakeEngine.cols,
          top: SnakeEngine.foodTop,
        );
        expect(cells, isNotEmpty);
        for (final (x, y) in cells) {
          expect(x, inInclusiveRange(0, SnakeEngine.cols - 1), reason: w);
          expect(
            y,
            inInclusiveRange(SnakeEngine.foodTop, SnakeEngine.foodTop + 5),
            reason: w,
          );
        }
      }
      expect(
        Glyphs.layout('GFG', cols: 23, top: SnakeEngine.foodTop),
        hasLength(43),
      );
    });

    test('starts on the bottom row, clear of the letters', () {
      final e = SnakeEngine();
      expect(e.status, SnakeStatus.ready);
      expect(e.snake, hasLength(3));
      expect(e.snake.first, (4, SnakeEngine.rows - 1));
      expect(e.snake.toSet().intersection(e.food), isEmpty);
      expect(e.word, 'GFG');
    });

    test('moves, ignores reversing, and wraps at the edges', () {
      final e = _running();
      e.step();
      expect(e.snake.first, (5, SnakeEngine.rows - 1));
      e.turn(Dir.left); // straight back into itself
      e.step();
      expect(e.dir, Dir.right);
      expect(e.snake.first, (6, SnakeEngine.rows - 1));

      const last = SnakeEngine.rows - 1;
      e.snake = [(22, last), (21, last), (20, last)];
      e.step();
      expect(e.snake.first, (0, last));
      e.turn(Dir.down);
      e.step();
      expect(e.snake.first, (0, 0)); // wrapped bottom to top
    });

    test('two quick swipes both land, one per move', () {
      final e = _running();
      e.turn(Dir.up);
      e.turn(Dir.left);
      e.step();
      expect(e.dir, Dir.up);
      e.step();
      expect(e.dir, Dir.left);
    });

    test('eating a lit square grows the snake and scores', () {
      final e = _running()..food = {(5, SnakeEngine.rows - 1), (9, 9)};
      e.step();
      expect(e.snake, hasLength(4));
      expect(e.food, {(9, 9)});
      expect(e.score, 10);
      expect(e.status, SnakeStatus.running);
    });

    test('eating the last square clears the word and unlocks the next', () {
      final e = _running()
        ..food = {(5, SnakeEngine.rows - 1)}
        ..foodAtStart = 1;
      e.step();
      expect(e.status, SnakeStatus.cleared);
      expect(e.score, 60); // 10 + level-one bonus of 50
      expect(e.best, 60);
      e.start();
      expect(e.level, 2);
      expect(e.word, 'KIIT');
      expect(e.status, SnakeStatus.running);
      expect(e.snake, hasLength(3));
      expect(e.tickMs, lessThan(190));
    });

    test('biting yourself ends the run and records the best', () {
      final e = _running();
      e.score = 120;
      e.snake = [(5, 14), (5, 15), (6, 15), (6, 14), (7, 14)];
      e.dir = Dir.right;
      e.step();
      expect(e.status, SnakeStatus.over);
      expect(e.best, 120);
      e.start(); // play again resets everything but the best
      expect(e.status, SnakeStatus.running);
      expect(e.score, 0);
      expect(e.level, 1);
      expect(e.best, 120);
    });

    test('chasing your own tail is fine', () {
      final e = _running();
      e.snake = [(5, 14), (5, 15), (6, 15), (6, 14)];
      e.dir = Dir.right;
      e.step();
      expect(e.status, SnakeStatus.running);
    });

    test('speed has a floor', () {
      final e = SnakeEngine()..level = 40;
      expect(e.tickMs, 85);
    });
  });

  group('registration rules', () {
    test('seats are shared between member RSVPs and guests', () {
      final e = _event(capacity: 10, rsvps: ['a', 'b', 'c']);
      expect(RegistrationRules.spotsLeft(e, 4), 3);
      expect(RegistrationRules.spotsLeft(_event(), 99), isNull);
      expect(RegistrationRules.spotsLeft(e, 50), 0);
    });

    test('blocks cancelled, finished, members-only and full', () {
      RegistrationBlock? b(
        SocietyEvent e, {
        int guests = 0,
        bool has = false,
      }) => RegistrationRules.blockFor(
        e,
        guestCount: guests,
        alreadyRegistered: has,
      );
      expect(b(_event()), isNull);
      expect(b(_event(cancelled: true)), RegistrationBlock.cancelled);
      expect(
        b(_event(start: const Duration(days: -3))),
        RegistrationBlock.ended,
      );
      expect(b(_event(isPublic: false)), RegistrationBlock.closed);
      expect(
        b(_event(capacity: 2, rsvps: ['a']), guests: 1),
        RegistrationBlock.full,
      );
      // Someone who already has a seat isn't told it's full.
      expect(
        b(_event(capacity: 2, rsvps: ['a']), guests: 1, has: true),
        isNull,
      );
    });

    test('validates name and email', () {
      expect(RegistrationRules.validateName(' '), isNotNull);
      expect(RegistrationRules.validateName('Asha'), isNull);
      expect(RegistrationRules.validateEmail('nope'), isNotNull);
      expect(RegistrationRules.validateEmail('asha@gmail.com'), isNull);
    });
  });

  group('guest registration', () {
    Future<ProviderContainer> boot() async {
      SharedPreferences.setMockInitialValues({});
      final store = await LocalStore.open();
      await Seed.run(store);
      final c = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(store)],
      );
      addTearDown(c.dispose);
      for (final p in [
        eventsProvider,
        registrationsProvider,
        organizationProvider,
      ]) {
        c.listen(p, (_, _) {});
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return c;
    }

    const asha = GuestProfile(
      name: 'Asha Rao',
      email: 'Asha@Gmail.com',
      college: 'KIIT',
    );
    const ravi = GuestProfile(name: 'Ravi', email: 'ravi@gmail.com');

    SocietyEvent upcoming(ProviderContainer c) =>
        c.read(publicEventsProvider).firstWhere((e) => !e.isPast());

    test('registers once per email and remembers the visitor', () async {
      final c = await boot();
      final e = upcoming(c);
      final actions = c.read(guestActionsProvider);
      await actions.register(e, asha);
      await actions.register(e, asha.copyWithName('Asha R'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final regs = c.read(eventRegistrationsProvider(e.id));
      expect(regs, hasLength(1));
      expect(regs.single.name, 'Asha R');
      expect(regs.single.email, 'asha@gmail.com');
      expect(c.read(guestProfileProvider)?.email, 'Asha@Gmail.com');
      expect(c.read(myRegistrationProvider(e.id)), isNotNull);
      expect(regs.single.reference, hasLength(6));

      await actions.cancel(regs.single);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.read(eventRegistrationsProvider(e.id)), isEmpty);
      expect(c.read(myRegistrationProvider(e.id)), isNull);
    });

    test('the last seat goes to one person, and frees up on cancel', () async {
      final c = await boot();
      final e = upcoming(c);
      final seats = e.rsvpIds.length + 1;
      await c.read(eventRepo).save(e.copyWith(capacity: seats));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final actions = c.read(guestActionsProvider);
      final fresh = c.read(eventMapProvider)[e.id]!;

      await actions.register(fresh, asha);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await expectLater(
        actions.register(fresh, ravi),
        throwsA(
          isA<StateError>().having(
            (x) => x.message,
            'message',
            'All seats are taken.',
          ),
        ),
      );
      await actions.cancel(c.read(eventRegistrationsProvider(e.id)).single);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await actions.register(fresh, ravi);
    });

    test('finished and members-only events refuse guests', () async {
      final c = await boot();
      final past = c.read(eventsProvider).firstWhere((e) => e.isPast());
      await expectLater(
        c.read(guestActionsProvider).register(past, asha),
        throwsStateError,
      );

      final e = upcoming(c);
      await c.read(eventRepo).save(e.copyWith(isPublic: false));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(
        c.read(publicEventsProvider).map((x) => x.id),
        isNot(contains(e.id)),
      );
      await expectLater(
        c
            .read(guestActionsProvider)
            .register(c.read(eventMapProvider)[e.id]!, asha),
        throwsStateError,
      );
    });
  });

  group('visitor screens', () {
    Future<ProviderContainer> open(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
      return ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
    }

    for (final size in [const Size(430, 932), const Size(1280, 900)]) {
      testWidgets(
        'visitor can browse, register and reach member login at ${size.width.toInt()}px',
        (tester) async {
          final c = await open(tester, size);
          final router = c.read(routerProvider);

          // Lands on the public home, not the login form.
          expect(router.state.matchedLocation, '/welcome');
          expect(find.text('Member login'), findsOneWidget);
          expect(tester.takeException(), isNull);

          for (final path in ['/welcome/study', '/welcome/play', '/welcome']) {
            router.go(path);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: path);
          }

          // Private pages bounce back to the public home.
          router.go('/funds');
          await tester.pumpAndSettle();
          expect(router.state.matchedLocation, '/welcome');

          // Every public event opens.
          for (final e in c.read(publicEventsProvider)) {
            router.go('/welcome/events/${e.id}');
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: e.id);
          }

          // Register through the UI.
          final e = c.read(publicEventsProvider).firstWhere((x) => !x.isPast());
          router.go('/welcome/events/${e.id}');
          await tester.pumpAndSettle();
          await tester.tap(find.byType(FilledButton).last);
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextFormField).at(0), 'Asha Rao');
          await tester.enterText(
            find.byType(TextFormField).at(1),
            'asha@gmail.com',
          );
          await tester.tap(
            find.widgetWithText(FilledButton, 'Confirm my seat'),
          );
          await tester.pumpAndSettle();
          expect(find.text('You’re registered'), findsOneWidget);
          expect(c.read(eventRegistrationsProvider(e.id)), hasLength(1));

          // Member login leads to the sign-in form, then into the panel.
          router.go('/welcome');
          await tester.pumpAndSettle();
          await tester.tap(find.text('Member login'));
          await tester.pumpAndSettle();
          expect(router.state.matchedLocation, '/login');
          await tester.enterText(
            find.byType(TextFormField).at(0),
            '2305318@kiit.ac.in',
          );
          await tester.enterText(
            find.byType(TextFormField).at(1),
            Seed.password,
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
          await tester.pumpAndSettle();
          expect(router.state.matchedLocation, '/home');

          // The game is also reachable from inside.
          router.go('/play');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Signing out returns to the public home.
          await c.read(authActionsProvider).signOut();
          await tester.pumpAndSettle();
          expect(router.state.matchedLocation, '/welcome');
        },
      );
    }

    testWidgets('snake plays from the Play tab and pauses when you leave', (
      tester,
    ) async {
      final c = await open(tester, const Size(430, 932));
      final router = c.read(routerProvider);
      router.go('/welcome/play');
      await tester.pumpAndSettle();
      expect(find.text('Ready?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Play'));
      await tester.pump();
      expect(find.text('Ready?'), findsNothing);
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);

      // The on-screen arrows steer the snake.
      await tester.tap(find.bySemanticsLabel('Up'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);

      // Switching tab pauses it rather than leaving it running unseen.
      router.go('/welcome');
      await tester.pumpAndSettle();
      router.go('/welcome/play');
      await tester.pumpAndSettle();
      expect(find.text('Paused'), findsOneWidget);
    });
  });
}

extension on GuestProfile {
  GuestProfile copyWithName(String n) =>
      GuestProfile(name: n, email: email, rollNo: rollNo, college: college);
}
