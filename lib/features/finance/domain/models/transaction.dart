import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType { income, expense }
enum TransactionStatus { pending, approved, rejected }

@freezed
class SocietyTransaction with _$SocietyTransaction {
  const factory SocietyTransaction({
    required String id,
    required String orgId,
    required double amount,
    required TransactionType type,
    required String category,
    required String description,
    required TransactionStatus status,
    required String requesterId,
    String? requesterName,
    String? approverId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SocietyTransaction;

  factory SocietyTransaction.fromJson(Map<String, dynamic> json) => _$SocietyTransactionFromJson(json);
}
