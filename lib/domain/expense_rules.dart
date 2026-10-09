import '../data/models/models.dart';
import 'access.dart';

/// The expense approval chain from doc §6, as pure functions.
///
/// Expense Submitted → Lead Review → Core Head Verification →
/// President/VP Approval → Wallet Updated → Audit Log.
///
/// Backend: run [decide] inside a Cloud Function (or a Firestore transaction
/// guarded by rules) so the client cannot skip steps.
abstract final class ExpenseRules {
  static const _chain = ExpenseStage.chain;

  static Permission permissionFor(ExpenseStage stage) => switch (stage) {
    ExpenseStage.leadReview => Permission.reviewExpense,
    ExpenseStage.headVerification => Permission.verifyExpense,
    _ => Permission.approveExpense,
  };

  /// Which stage a new expense starts at. Submitters skip the steps at or
  /// below their own level; anything not tied to a domain goes straight to
  /// final approval.
  static ExpenseStage entryStage({
    required Role submitterRole,
    required String? domainId,
  }) {
    if (domainId == null) return ExpenseStage.finalApproval;
    return switch (submitterRole.tier) {
      RoleTier.member => ExpenseStage.leadReview,
      RoleTier.lead => ExpenseStage.headVerification,
      RoleTier.core || RoleTier.leadership => ExpenseStage.finalApproval,
    };
  }

  /// Can [a] act on [stage] for an expense in [domainId]?
  static bool _canActAt(Access a, ExpenseStage stage, String? domainId) {
    final p = permissionFor(stage);
    if (!a.can(p)) return false;
    if (stage == ExpenseStage.finalApproval) return a.isSocietyWide;
    return domainId == null ? a.isSocietyWide : a.reaches(domainId: domainId);
  }

  /// Highest open stage [a] could sign off on for this expense, or null.
  static ExpenseStage? highestStageFor(Access a, Expense e) {
    ExpenseStage? best;
    for (final s in _chain) {
      if (_chain.indexOf(s) < _chain.indexOf(e.stage)) continue;
      if (_canActAt(a, s, e.domainId)) best = s;
    }
    return best;
  }

  /// Nobody approves their own claim. Someone higher up the chain may step in
  /// for a missing lead (e.g. the Technical Head reviewing for App Dev).
  static bool canAct(Access a, Expense e) =>
      e.stage.isOpen &&
      e.submittedBy != a.me.id &&
      highestStageFor(a, e) != null;

  /// Stage after [a] approves. Approving with more authority than the current
  /// step needs skips the steps in between.
  static ExpenseStage stageAfterApproval(Access a, Expense e) {
    final top = highestStageFor(a, e) ?? e.stage;
    final i = _chain.indexOf(top);
    return i + 1 < _chain.length ? _chain[i + 1] : ExpenseStage.approved;
  }

  /// Returns the updated expense. Throws [StateError] if [a] may not act.
  static Expense decide(
    Access a,
    Expense e, {
    required bool approve,
    String note = '',
    DateTime? now,
  }) {
    if (!canAct(a, e)) throw StateError('You can’t act on this expense.');
    if (!approve && note.trim().isEmpty) {
      throw ArgumentError('Add a reason so the submitter knows what to fix.');
    }
    final at = now ?? DateTime.now();
    final step = ApprovalStep(
      stage: highestStageFor(a, e)!,
      decision: approve ? ApprovalDecision.approved : ApprovalDecision.rejected,
      actorId: a.me.id,
      at: at,
      note: note.trim(),
    );
    return e.copyWith(
      stage: approve ? stageAfterApproval(a, e) : ExpenseStage.rejected,
      history: [...e.history, step],
    );
  }

  /// Who needs to act next — used to route notifications.
  static List<Member> nextActors(
    Expense e, {
    required List<Member> members,
    required Map<String, Role> roles,
    required Map<String, Domain> domains,
  }) {
    if (!e.stage.isOpen) return const [];
    return members.where((m) {
      final role = roles[m.roleId];
      if (role == null || !m.isActive || m.id == e.submittedBy) return false;
      final access = Access(me: m, role: role, domains: domains);
      return _canActAt(access, e.stage, e.domainId);
    }).toList();
  }
}

/// Money maths shared by the wallet, event budgets and the term report.
abstract final class Ledger {
  static double incomeTotal(Iterable<Income> income) =>
      income.fold(0, (s, i) => s + i.amount);

  static double spentTotal(Iterable<Expense> expenses) =>
      expenses.where((e) => e.isApproved).fold(0, (s, e) => s + e.amount);

  static double pendingTotal(Iterable<Expense> expenses) =>
      expenses.where((e) => e.stage.isOpen).fold(0, (s, e) => s + e.amount);

  static double balance(Iterable<Income> income, Iterable<Expense> expenses) =>
      incomeTotal(income) - spentTotal(expenses);

  static double eventSpent(String eventId, Iterable<Expense> expenses) =>
      spentTotal(expenses.where((e) => e.eventId == eventId));

  static double eventCommitted(String eventId, Iterable<Expense> expenses) =>
      pendingTotal(expenses.where((e) => e.eventId == eventId));
}
