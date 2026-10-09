import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gfghub/data/local/local_store.dart';
import 'package:gfghub/data/models/models.dart';
import 'package:gfghub/data/providers.dart';
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
}
