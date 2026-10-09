import 'json.dart';

enum ExpenseCategory {
  venue('Venue'),
  food('Food & refreshments'),
  printing('Printing'),
  prizes('Prizes'),
  swag('Swag & merch'),
  travel('Travel'),
  software('Software & hosting'),
  logistics('Logistics'),
  other('Other');

  const ExpenseCategory(this.label);
  final String label;
}

/// Where an expense sits in the approval chain (doc §6):
/// Submitted → Lead review → Core head verification → President/VP approval.
enum ExpenseStage {
  leadReview('Lead review'),
  headVerification('Core head verification'),
  finalApproval('Final approval'),
  approved('Approved'),
  rejected('Rejected');

  const ExpenseStage(this.label);
  final String label;

  bool get isOpen => this != approved && this != rejected;

  /// The open stages, in order.
  static const chain = [leadReview, headVerification, finalApproval];
}

enum ApprovalDecision {
  submitted('Submitted'),
  approved('Approved'),
  rejected('Rejected'),
  reimbursed('Reimbursed');

  const ApprovalDecision(this.label);
  final String label;
}

/// One line in the expense's audit trail. Never edited, only appended.
class ApprovalStep {
  const ApprovalStep({
    required this.stage,
    required this.decision,
    required this.actorId,
    required this.at,
    this.note = '',
  });

  /// Stage the decision was made at (submitted uses [ExpenseStage.leadReview]
  /// or whichever stage the expense entered).
  final ExpenseStage stage;
  final ApprovalDecision decision;
  final String actorId;
  final DateTime at;
  final String note;

  factory ApprovalStep.fromJson(Json j) => ApprovalStep(
    stage: readEnum(ExpenseStage.values, j['stage'], ExpenseStage.leadReview),
    decision: readEnum(
      ApprovalDecision.values,
      j['decision'],
      ApprovalDecision.submitted,
    ),
    actorId: j['actorId'] as String,
    at: readDate(j['at']),
    note: j['note'] as String? ?? '',
  );

  Json toJson() => {
    'stage': stage.name,
    'decision': decision.name,
    'actorId': actorId,
    'at': writeDate(at),
    'note': note,
  };
}

class Expense implements Entity {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.submittedBy,
    required this.submittedAt,
    required this.stage,
    this.description = '',
    this.domainId,
    this.eventId,
    this.receiptName,
    this.receiptRef,
    this.history = const [],
    this.reimbursedAt,
    this.paymentRef = '',
  });

  @override
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String description;

  /// Submitter's domain at the time of submission (drives who reviews it).
  final String? domainId;
  final String? eventId;
  final String submittedBy;
  final DateTime submittedAt;

  /// File name shown in the UI.
  final String? receiptName;

  /// Where the receipt lives. Local path today; Storage path once the backend
  /// is in (`orgs/{orgId}/receipts/{expenseId}`).
  final String? receiptRef;
  final ExpenseStage stage;
  final List<ApprovalStep> history;
  final DateTime? reimbursedAt;
  final String paymentRef;

  bool get isApproved => stage == ExpenseStage.approved;
  bool get isReimbursed => reimbursedAt != null;

  DateTime get decidedAt => history.isEmpty ? submittedAt : history.last.at;

  Expense copyWith({
    ExpenseStage? stage,
    List<ApprovalStep>? history,
    DateTime? reimbursedAt,
    String? paymentRef,
  }) => Expense(
    id: id,
    title: title,
    amount: amount,
    category: category,
    description: description,
    domainId: domainId,
    eventId: eventId,
    submittedBy: submittedBy,
    submittedAt: submittedAt,
    receiptName: receiptName,
    receiptRef: receiptRef,
    stage: stage ?? this.stage,
    history: history ?? this.history,
    reimbursedAt: reimbursedAt ?? this.reimbursedAt,
    paymentRef: paymentRef ?? this.paymentRef,
  );

  factory Expense.fromJson(Json j) => Expense(
    id: j['id'] as String,
    title: j['title'] as String,
    amount: readDouble(j['amount']),
    category: readEnum(
      ExpenseCategory.values,
      j['category'],
      ExpenseCategory.other,
    ),
    description: j['description'] as String? ?? '',
    domainId: j['domainId'] as String?,
    eventId: j['eventId'] as String?,
    submittedBy: j['submittedBy'] as String,
    submittedAt: readDate(j['submittedAt']),
    receiptName: j['receiptName'] as String?,
    receiptRef: j['receiptRef'] as String?,
    stage: readEnum(ExpenseStage.values, j['stage'], ExpenseStage.leadReview),
    history: readList(j['history'], ApprovalStep.fromJson),
    reimbursedAt: readDateOrNull(j['reimbursedAt']),
    paymentRef: j['paymentRef'] as String? ?? '',
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category.name,
    'description': description,
    'domainId': domainId,
    'eventId': eventId,
    'submittedBy': submittedBy,
    'submittedAt': writeDate(submittedAt),
    'receiptName': receiptName,
    'receiptRef': receiptRef,
    'stage': stage.name,
    'history': history.map((h) => h.toJson()).toList(),
    'reimbursedAt': writeDate(reimbursedAt),
    'paymentRef': paymentRef,
  };
}

enum IncomeSource {
  sponsorship('Sponsorship'),
  grant('Chapter grant'),
  membershipFee('Membership fees'),
  ticketSales('Ticket sales'),
  other('Other');

  const IncomeSource(this.label);
  final String label;
}

class Income implements Entity {
  const Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.source,
    required this.loggedBy,
    required this.receivedAt,
    this.eventId,
    this.note = '',
    this.reference = '',
  });

  @override
  final String id;
  final String title;
  final double amount;
  final IncomeSource source;
  final String? eventId;
  final String loggedBy;
  final DateTime receivedAt;
  final String note;

  /// UTR / cheque / invoice number.
  final String reference;

  factory Income.fromJson(Json j) => Income(
    id: j['id'] as String,
    title: j['title'] as String,
    amount: readDouble(j['amount']),
    source: readEnum(IncomeSource.values, j['source'], IncomeSource.other),
    eventId: j['eventId'] as String?,
    loggedBy: j['loggedBy'] as String,
    receivedAt: readDate(j['receivedAt']),
    note: j['note'] as String? ?? '',
    reference: j['reference'] as String? ?? '',
  );

  @override
  Json toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'source': source.name,
    'eventId': eventId,
    'loggedBy': loggedBy,
    'receivedAt': writeDate(receivedAt),
    'note': note,
    'reference': reference,
  };
}
