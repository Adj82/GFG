import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../expense_rules.dart';
import 'base.dart';

final financeActionsProvider = Provider((ref) => FinanceActions(ref));

class FinanceActions extends ActionsBase {
  FinanceActions(super.ref);

  List<String> _nextActorIds(Expense e) => ExpenseRules.nextActors(
    e,
    members: ref.read(activeMembersProvider),
    roles: ref.read(roleMapProvider),
    domains: ref.read(domainMapProvider),
  ).map((m) => m.id).toList();

  Future<Expense> submit({
    required String title,
    required double amount,
    required ExpenseCategory category,
    String description = '',
    String? eventId,
    String? receiptName,
    String? receiptRef,
  }) async {
    final me = access.me;
    final domainId = me.domainId;
    final stage = ExpenseRules.entryStage(
      submitterRole: access.role,
      domainId: domainId,
    );
    final e = Expense(
      id: newId(),
      title: title.trim(),
      amount: amount,
      category: category,
      description: description.trim(),
      domainId: domainId,
      eventId: eventId,
      submittedBy: me.id,
      submittedAt: now,
      receiptName: receiptName,
      receiptRef: receiptRef,
      stage: stage,
      history: [
        ApprovalStep(
          stage: stage,
          decision: ApprovalDecision.submitted,
          actorId: me.id,
          at: now,
        ),
      ],
    );
    await ref.read(expenseRepo).save(e);
    await notify(
      _nextActorIds(e),
      kind: NoticeKind.finance,
      title: 'Expense to review: ${Fmt.money(amount)}',
      body: '${me.name} · ${e.title}',
      route: '/funds/expense/${e.id}',
    );
    await audit(
      'expense.submitted',
      '${me.name} submitted ${Fmt.money(amount)} for ${e.title}',
      targetId: e.id,
    );
    return e;
  }

  Future<void> decide(
    Expense e, {
    required bool approve,
    String note = '',
  }) async {
    final updated = ExpenseRules.decide(
      access,
      e,
      approve: approve,
      note: note,
    );
    await ref.read(expenseRepo).save(updated);

    final who = access.me.name;
    if (!approve) {
      await notify(
        [e.submittedBy],
        kind: NoticeKind.finance,
        title: 'Expense returned: ${e.title}',
        body: '$who: ${note.trim()}',
        route: '/funds/expense/${e.id}',
      );
      await audit(
        'expense.rejected',
        '$who rejected ${Fmt.money(e.amount)} for ${e.title}',
        targetId: e.id,
      );
      return;
    }

    if (updated.isApproved) {
      await notify(
        [e.submittedBy],
        kind: NoticeKind.finance,
        title: 'Expense approved: ${Fmt.money(e.amount)}',
        body: '${e.title} is approved. You will be reimbursed.',
        route: '/funds/expense/${e.id}',
      );
      await notify(
        holdersOf(Permission.reimburse),
        kind: NoticeKind.finance,
        title: 'To reimburse: ${Fmt.money(e.amount)}',
        body: '${nameOf(e.submittedBy)} · ${e.title}',
        route: '/funds/expense/${e.id}',
      );
      await audit(
        'expense.approved',
        '$who gave final approval to ${Fmt.money(e.amount)} for ${e.title}',
        targetId: e.id,
      );
    } else {
      await notify(
        _nextActorIds(updated),
        kind: NoticeKind.finance,
        title: 'Expense to review: ${Fmt.money(e.amount)}',
        body:
            '${nameOf(e.submittedBy)} · ${e.title} · passed ${e.stage.label.toLowerCase()}',
        route: '/funds/expense/${e.id}',
      );
      await notify(
        [e.submittedBy],
        kind: NoticeKind.finance,
        title: 'Expense moved to ${updated.stage.label.toLowerCase()}',
        body: '$who approved ${e.title}.',
        route: '/funds/expense/${e.id}',
      );
      await audit(
        'expense.forwarded',
        '$who passed ${e.title} to ${updated.stage.label.toLowerCase()}',
        targetId: e.id,
      );
    }
  }

  Future<void> markReimbursed(Expense e, {String paymentRef = ''}) async {
    if (!access.can(Permission.reimburse) || !e.isApproved || e.isReimbursed) {
      return;
    }
    await ref
        .read(expenseRepo)
        .save(
          e.copyWith(
            reimbursedAt: now,
            paymentRef: paymentRef.trim(),
            history: [
              ...e.history,
              ApprovalStep(
                stage: ExpenseStage.approved,
                decision: ApprovalDecision.reimbursed,
                actorId: myId,
                at: now,
                note: paymentRef.trim(),
              ),
            ],
          ),
        );
    await notify(
      [e.submittedBy],
      kind: NoticeKind.finance,
      title: 'Reimbursed: ${Fmt.money(e.amount)}',
      body:
          '${e.title}${paymentRef.trim().isEmpty ? '' : ' · ref ${paymentRef.trim()}'}',
      route: '/funds/expense/${e.id}',
    );
    await audit(
      'expense.reimbursed',
      '${access.me.name} reimbursed ${Fmt.money(e.amount)} for ${e.title}',
      targetId: e.id,
    );
  }

  Future<void> logIncome({
    required String title,
    required double amount,
    required IncomeSource source,
    required DateTime receivedAt,
    String? eventId,
    String note = '',
    String reference = '',
  }) async {
    if (!access.can(Permission.logIncome)) {
      throw StateError('You can’t log income.');
    }
    final i = Income(
      id: newId(),
      title: title.trim(),
      amount: amount,
      source: source,
      eventId: eventId,
      loggedBy: myId,
      receivedAt: receivedAt,
      note: note.trim(),
      reference: reference.trim(),
    );
    await ref.read(incomeRepo).save(i);
    await notify(
      holdersOf(Permission.viewWallet),
      kind: NoticeKind.finance,
      title: 'Income logged: ${Fmt.money(amount)}',
      body: '${i.title} · ${source.label}',
      route: '/funds',
    );
    await audit(
      'income.logged',
      '${access.me.name} logged ${Fmt.money(amount)} from ${i.title}',
      targetId: i.id,
    );
  }
}
