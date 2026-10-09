import 'package:flutter_test/flutter_test.dart';
import 'package:gfghub/data/local/local_repository.dart';
import 'package:gfghub/data/local/local_store.dart';
import 'package:gfghub/data/models/models.dart';
import 'package:gfghub/data/repositories/repository.dart';
import 'package:gfghub/data/seed/seed.dart';
import 'package:gfghub/domain/access.dart';
import 'package:gfghub/domain/checkin_code.dart';
import 'package:gfghub/domain/default_roles.dart';
import 'package:gfghub/domain/expense_rules.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<
  ({
    Map<String, Member> byRoll,
    Map<String, Role> roles,
    Map<String, Domain> domains,
  })
>
_load() async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocalStore.open();
  await Seed.run(store);
  final members = await LocalRepository<Member>(
    store,
    Collections.members,
    Member.fromJson,
  ).fetchAll();
  final roles = await LocalRepository<Role>(
    store,
    Collections.roles,
    Role.fromJson,
  ).fetchAll();
  final domains = await LocalRepository<Domain>(
    store,
    Collections.domains,
    Domain.fromJson,
  ).fetchAll();
  return (
    byRoll: {for (final m in members) m.rollNo: m},
    roles: {for (final r in roles) r.id: r},
    domains: {for (final d in domains) d.id: d},
  );
}

Expense _expense({
  required String by,
  String? domain,
  ExpenseStage stage = ExpenseStage.leadReview,
  double amount = 500,
}) => Expense(
  id: 'x',
  title: 'Snacks',
  amount: amount,
  category: ExpenseCategory.food,
  submittedBy: by,
  submittedAt: DateTime(2026, 1, 1),
  stage: stage,
  domainId: domain,
);

void main() {
  group('CheckInCode', () {
    final t = DateTime.utc(2026, 1, 1, 10, 0, 5);
    test('is stable inside a window and rotates after it', () {
      final a = CheckInCode.codeAt('s', 'e1', t);
      expect(
        CheckInCode.codeAt('s', 'e1', t.add(const Duration(seconds: 10))),
        a,
      );
      expect(
        CheckInCode.codeAt('s', 'e1', t.add(const Duration(seconds: 40))),
        isNot(a),
      );
      expect(a, matches(RegExp(r'^\d{6}$')));
    });

    test('accepts current and previous window only', () {
      final old = CheckInCode.codeAt('s', 'e1', t);
      expect(
        CheckInCode.verify('s', 'e1', old, t.add(const Duration(seconds: 20))),
        isTrue,
      );
      expect(
        CheckInCode.verify('s', 'e1', old, t.add(const Duration(seconds: 100))),
        isFalse,
      );
    });

    test('is bound to the event and secret', () {
      final c = CheckInCode.codeAt('s', 'e1', t);
      expect(CheckInCode.verify('s', 'e2', c, t), isFalse);
      expect(CheckInCode.verify('other', 'e1', c, t), isFalse);
    });

    test('QR payload round-trips', () {
      final p = CheckInCode.payload('ev9', '123456');
      expect(CheckInCode.parse(p), (eventId: 'ev9', code: '123456'));
      expect(CheckInCode.parse('https://evil.example/?e=1&c=2'), isNull);
    });
  });

  group('Ledger', () {
    test('balance = income - approved spend; pending is separate', () {
      final income = [
        Income(
          id: 'i',
          title: 'Sponsor',
          amount: 10000,
          source: IncomeSource.sponsorship,
          receivedAt: DateTime(2026),
          loggedBy: 'u',
        ),
      ];
      final expenses = [
        _expense(by: 'a', stage: ExpenseStage.approved, amount: 1500),
        _expense(by: 'a', stage: ExpenseStage.leadReview, amount: 700),
        _expense(by: 'a', stage: ExpenseStage.rejected, amount: 9999),
      ];
      expect(Ledger.incomeTotal(income), 10000);
      expect(Ledger.spentTotal(expenses), 1500);
      expect(Ledger.pendingTotal(expenses), 700);
      expect(Ledger.balance(income, expenses), 8500);
    });
  });

  group('Permissions and approval chain (seeded GFG KIIT)', () {
    test('entry stage depends on who submits', () async {
      final d = await _load();
      Role role(String id) => d.roles[id]!;
      expect(
        ExpenseRules.entryStage(
          submitterRole: role(DefaultRoles.member),
          domainId: 'app_dev',
        ),
        ExpenseStage.leadReview,
      );
      expect(
        ExpenseRules.entryStage(
          submitterRole: role(DefaultRoles.domainLead),
          domainId: 'app_dev',
        ),
        ExpenseStage.headVerification,
      );
      expect(
        ExpenseRules.entryStage(
          submitterRole: role(DefaultRoles.technicalHead),
          domainId: 'app_dev',
        ),
        ExpenseStage.finalApproval,
      );
      expect(
        ExpenseRules.entryStage(
          submitterRole: role(DefaultRoles.member),
          domainId: null,
        ),
        ExpenseStage.finalApproval,
      );
    });

    test(
      'nobody approves their own claim; plain members cannot approve',
      () async {
        final d = await _load();
        Access access(String roll) {
          final m = d.byRoll[roll]!;
          return Access(me: m, role: d.roles[m.roleId]!, domains: d.domains);
        }

        final member = access('2305318');
        final president = access('2105101');
        final own = _expense(
          by: president.me.id,
          stage: ExpenseStage.finalApproval,
        );
        expect(
          ExpenseRules.canAct(president, own),
          isFalse,
          reason: 'self-approval',
        );
        final theirs = _expense(
          by: member.me.id,
          stage: ExpenseStage.finalApproval,
        );
        expect(ExpenseRules.canAct(president, theirs), isTrue);
        expect(ExpenseRules.canAct(member, theirs), isFalse);
        expect(
          () => ExpenseRules.decide(member, theirs, approve: true),
          throwsStateError,
        );
      },
    );

    test('final approval completes; returning needs a reason', () async {
      final d = await _load();
      final m = d.byRoll['2105101']!;
      final president = Access(
        me: m,
        role: d.roles[m.roleId]!,
        domains: d.domains,
      );
      final e = _expense(by: 'someone-else', stage: ExpenseStage.finalApproval);
      final done = ExpenseRules.decide(president, e, approve: true);
      expect(done.stage, ExpenseStage.approved);
      expect(done.history.last.decision, ApprovalDecision.approved);
      expect(
        () => ExpenseRules.decide(president, e, approve: false),
        throwsArgumentError,
      );
      final back = ExpenseRules.decide(
        president,
        e,
        approve: false,
        note: 'Missing bill',
      );
      expect(back.stage, ExpenseStage.rejected);
    });

    test('a member cannot manage anyone', () async {
      final d = await _load();
      final m = d.byRoll['2305318']!;
      final a = Access(me: m, role: d.roles[m.roleId]!, domains: d.domains);
      expect(a.can(Permission.manageMembers), isFalse);
      expect(a.can(Permission.viewWallet), isFalse);
      expect(a.canManageMember(d.byRoll['2205077']!), isFalse);
    });
  });

  group('core team', () {
    test('only the six core roles see the treasury and every domain', () async {
      final d = await _load();
      bool can(String roll, Permission p) {
        final m = d.byRoll[roll]!;
        return Access(
          me: m,
          role: d.roles[m.roleId]!,
          domains: d.domains,
        ).can(p);
      }

      // President, VP, Technical, Event, Sponsorship, Marketing heads.
      for (final roll in [
        '2105101',
        '2105188',
        '2205140',
        '2205162',
        '2205170',
        '2205171',
      ]) {
        expect(can(roll, Permission.viewWallet), isTrue, reason: roll);
        expect(can(roll, Permission.viewAllDomains), isTrue, reason: roll);
      }
      // A domain lead and a plain member see neither.
      for (final roll in ['2205211', '2305318']) {
        expect(can(roll, Permission.viewWallet), isFalse, reason: roll);
        expect(can(roll, Permission.viewAllDomains), isFalse, reason: roll);
      }
    });

    test('coreIds names exactly six roles that exist', () async {
      final d = await _load();
      expect(DefaultRoles.coreIds, hasLength(6));
      for (final id in DefaultRoles.coreIds) {
        expect(d.roles.containsKey(id), isTrue, reason: id);
      }
    });
  });
}
