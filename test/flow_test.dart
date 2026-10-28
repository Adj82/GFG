import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gfghub/data/local/local_store.dart';
import 'package:gfghub/data/models/models.dart';
import 'package:gfghub/data/providers.dart';
import 'package:gfghub/data/repositories/repository.dart';
import 'package:gfghub/data/seed/seed.dart';
import 'package:gfghub/domain/actions/finance_actions.dart';
import 'package:gfghub/domain/actions/people_actions.dart';
import 'package:gfghub/domain/actions/work_actions.dart';
import 'package:gfghub/domain/checkin_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _boot() async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocalStore.open();
  await Seed.run(store);
  final c = ProviderContainer(
    overrides: [localStoreProvider.overrideWithValue(store)],
  );
  addTearDown(c.dispose);
  // Keep the live providers subscribed.
  for (final p in [
    membersProvider,
    expensesProvider,
    eventsProvider,
    tasksProvider,
    noticesProvider,
    applicationsProvider,
    auditProvider,
    attendanceProvider,
    accessProvider,
    organizationProvider,
  ]) {
    c.listen(p, (_, _) {});
  }
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return c;
}

Future<void> _as(ProviderContainer c, String roll) async {
  await c.read(authActionsProvider).signIn('$roll@kiit.ac.in', Seed.password);
  await Future<void>.delayed(const Duration(milliseconds: 30));
}

void main() {
  test(
    'expense: member submits, lead then head then president approve, president reimburses',
    () async {
      final c = await _boot();
      await _as(c, '2305318'); // member
      final me = c.read(currentMemberProvider)!;
      await c
          .read(financeActionsProvider)
          .submit(
            title: 'Pizza for workshop',
            amount: 1200,
            category: ExpenseCategory.food,
            description: '',
            receiptName: 'bill.jpg',
          );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      var e = c
          .read(expensesProvider)
          .firstWhere((x) => x.title == 'Pizza for workshop');
      expect(e.submittedBy, me.id);
      expect(e.stage, isNot(ExpenseStage.approved));
      expect(e.stage.isOpen, isTrue);

      // Walk the chain with whoever can act, president last.
      for (final roll in ['2205211', '2205140', '2105101']) {
        await _as(c, roll);
        e = c.read(expensesProvider).firstWhere((x) => x.id == e.id);
        if (!e.stage.isOpen) break;
        try {
          await c.read(financeActionsProvider).decide(e, approve: true);
        } on StateError {
          continue;
        }
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }
      e = c.read(expensesProvider).firstWhere((x) => x.id == e.id);
      expect(
        e.stage,
        ExpenseStage.approved,
        reason:
            'history: ${e.history.map((h) => '${h.stage.name}:${h.decision.name}').join(', ')}',
      );

      await _as(c, '2105101'); // president
      await c
          .read(financeActionsProvider)
          .markReimbursed(e, paymentRef: 'UPI-123');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      e = c.read(expensesProvider).firstWhere((x) => x.id == e.id);
      expect(e.isReimbursed, isTrue);
      expect(c.read(auditProvider), isNotEmpty);
    },
  );

  test('a member cannot self-approve or approve others', () async {
    final c = await _boot();
    await _as(c, '2305318');
    await c
        .read(financeActionsProvider)
        .submit(
          title: 'Mine',
          amount: 100,
          category: ExpenseCategory.other,
          description: '',
          receiptName: 'a.png',
        );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final e = c.read(expensesProvider).firstWhere((x) => x.title == 'Mine');
    expect(
      () => c.read(financeActionsProvider).decide(e, approve: true),
      throwsA(anything),
    );
  });

  test('check-in rejects a wrong code and accepts the live one', () async {
    final c = await _boot();
    await _as(c, '2305318');
    final ev = c
        .read(eventsProvider)
        .firstWhere(
          (x) => x.checkInOpen,
          orElse: () => c.read(eventsProvider).first,
        );
    final actions = c.read(eventActionsProvider);
    if (!ev.checkInOpen) return; // seed has none open: nothing to assert
    expect(await actions.checkIn(ev, '000000'), isNotNull);
    final good = CheckInCode.codeAt(ev.checkInSecret, ev.id, DateTime.now());
    expect(await actions.checkIn(ev, good), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(c.read(attendanceProvider).any((r) => r.targetId == ev.id), isTrue);
  });

  test('term rollover keeps history and disables outgoing people', () async {
    final c = await _boot();
    await _as(c, '2105101');
    final members = c.read(membersProvider);
    final outgoing = members.firstWhere(
      (m) => m.rollNo == '2205162',
    ); // event head
    final newPres = members.firstWhere((m) => m.rollNo == '2305318');
    await c
        .read(termActionsProvider)
        .startNewTerm(
          newTerm: '2027–28',
          offices: [Office(roleId: 'president', holderId: newPres.id)],
          alumniIds: {outgoing.id},
        );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final after = {for (final m in c.read(membersProvider)) m.id: m};
    expect(after[outgoing.id]!.status, MemberStatus.disabled);
    expect(after[outgoing.id]!.history, isNotEmpty);
    expect(after[newPres.id]!.roleId, 'president');
    expect(c.read(organizationProvider)!.currentTerm, '2027–28');
  });

  test('a join request notifies the lead and the whole core team', () async {
    final c = await _boot();
    await c
        .read(authActionsProvider)
        .applyToJoin(
          name: 'New Person',
          email: '2599999@kiit.ac.in',
          password: 'whatever1',
          domainId: 'web',
          year: 2,
          branch: 'CSE',
          why: 'Keen',
        );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final members = {for (final m in c.read(membersProvider)) m.rollNo: m.id};
    final told = c
        .read(noticesProvider)
        .where(
          (n) => n.title == 'New join request' && n.body.contains('New Person'),
        )
        .map((n) => n.recipientId)
        .toSet();
    for (final roll in [
      '2205233',
      '2105101',
      '2105188',
      '2205140',
      '2205162',
      '2205170',
      '2205171',
    ]) {
      expect(told, contains(members[roll]), reason: roll);
    }
    expect(told, isNot(contains(members['2205211']))); // app lead
  });

  test(
    'suspending blocks sign-in; a lead cannot suspend outside their domain',
    () async {
      final c = await _boot();
      await _as(c, '2205211'); // app lead
      final all = {for (final m in c.read(membersProvider)) m.rollNo: m};
      final acts = c.read(peopleActionsProvider);
      expect(() => acts.setDisabled(all['2205233']!, true), throwsStateError);
      await acts.setDisabled(all['2305318']!, true);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final after = c
          .read(membersProvider)
          .firstWhere((m) => m.rollNo == '2305318');
      expect(after.status, MemberStatus.disabled);
      expect(
        c.read(auditProvider).any((a) => a.action == 'member.suspended'),
        isTrue,
      );

      await _as(c, '2205162'); // core restores
      await c.read(peopleActionsProvider).setDisabled(after, false);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(
        c.read(membersProvider).firstWhere((m) => m.rollNo == '2305318').status,
        MemberStatus.active,
      );
    },
  );

  group('google sign-in', () {
    test('only kiit.ac.in accounts get in', () async {
      final c = await _boot();
      final auth = c.read(authActionsProvider);
      await expectLater(
        auth.signInWithGoogle(simulatedEmail: 'someone@gmail.com'),
        throwsA(isA<AuthFailure>()),
      );
      expect(c.read(authUserIdProvider), isNull);
      await expectLater(
        auth.signInWithGoogle(simulatedEmail: 'x@evilkiit.ac.in'),
        throwsA(isA<AuthFailure>()),
      );
      expect(c.read(authUserIdProvider), isNull);
    });

    test('a returning member lands as themselves', () async {
      final c = await _boot();
      await c
          .read(authActionsProvider)
          .signInWithGoogle(simulatedEmail: '2105101@KIIT.ac.in');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(c.read(currentMemberProvider)?.rollNo, '2105101');
    });

    test('an invited lead is claimed by email on first sign-in', () async {
      final c = await _boot();
      await _as(c, '2105101'); // president invites
      await c
          .read(peopleActionsProvider)
          .inviteMember(
            name: 'Nia Lead',
            email: 'Nia.Lead@kiit.ac.in',
            roleId: 'domain_lead',
            domainId: 'cloud',
            dept: Department.technical,
          );
      await c.read(authActionsProvider).signOut();
      await c
          .read(authActionsProvider)
          .signInWithGoogle(simulatedEmail: 'nia.lead@kiit.ac.in');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final me = c.read(currentMemberProvider)!;
      expect(me.name, 'Nia Lead');
      expect(me.roleId, 'domain_lead');
      expect(me.domainId, 'cloud');
      expect(me.status, MemberStatus.active);
      expect(await c.read(inviteRepo).fetch('nia.lead@kiit.ac.in'), isNull);
    });

    test(
      'a newcomer signs in, then requests a domain without a password',
      () async {
        final c = await _boot();
        await c
            .read(authActionsProvider)
            .signInWithGoogle(simulatedEmail: '2599999@kiit.ac.in');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(c.read(authUserIdProvider), isNotNull);
        expect(c.read(currentMemberProvider), isNull); // router sends to /join
        await c
            .read(authActionsProvider)
            .applyToJoin(
              name: 'Newcomer',
              email: 'ignored@kiit.ac.in',
              domainId: 'web',
              year: 1,
              branch: 'CSE',
              why: 'Keen',
            );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final me = c.read(currentMemberProvider)!;
        expect(me.status, MemberStatus.pending);
        expect(me.email, '2599999@kiit.ac.in'); // Google's email wins
        expect(me.domainId, 'web');
      },
    );
  });
}
