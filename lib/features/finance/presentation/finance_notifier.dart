import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/transaction.dart';
import '../../../core/persistence/local_storage_service.dart';
import '../../../main.dart';
import '../../../core/mock/mock_data.dart';
import 'package:uuid/uuid.dart';

class FinanceNotifier extends StateNotifier<List<SocietyTransaction>> {
  final LocalStorageService _storage;
  static const String _storageKey = 'society_transactions';

  FinanceNotifier(this._storage) : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    final data = _storage.getData(_storageKey);
    if (data != null) {
      final List<dynamic> list = data;
      state = list.map((e) => SocietyTransaction.fromJson(e)).toList();
    } else {
      // Seed with initial mock transactions
      state = [
        SocietyTransaction(
          id: const Uuid().v4(),
          orgId: MockData.orgId,
          amount: 50000.0,
          type: TransactionType.income,
          category: 'Sponsorship',
          description: 'Annual sponsorship from GFG Main.',
          status: TransactionStatus.approved,
          requesterId: 'user-pres',
          requesterName: 'Aditya Raj',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];
      _saveTransactions();
    }
  }

  void _saveTransactions() {
    _storage.saveData(_storageKey, state.map((e) => e.toJson()).toList());
  }

  void addTransaction(SocietyTransaction tx) {
    state = [tx, ...state];
    _saveTransactions();
  }

  void updateTransactionStatus(String id, TransactionStatus status, String approverId) {
    state = [
      for (final tx in state)
        if (tx.id == id)
          tx.copyWith(
            status: status,
            approverId: approverId,
            updatedAt: DateTime.now(),
          )
        else
          tx
    ];
    _saveTransactions();
  }

  double get balance {
    double bal = 0;
    for (final tx in state) {
      if (tx.status == TransactionStatus.approved) {
        if (tx.type == TransactionType.income) {
          bal += tx.amount;
        } else {
          bal -= tx.amount;
        }
      }
    }
    return bal;
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, List<SocietyTransaction>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return FinanceNotifier(storage);
});

final walletBalanceProvider = Provider<double>((ref) {
  return ref.watch(financeProvider.notifier).balance;
});
