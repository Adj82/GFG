import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/resource.dart';
import '../../../core/persistence/local_storage_service.dart';
import '../../../main.dart';
import '../../../core/mock/mock_data.dart';
import 'package:uuid/uuid.dart';

class VaultNotifier extends StateNotifier<List<SocietyResource>> {
  final LocalStorageService _storage;
  static const String _storageKey = 'society_vault';

  VaultNotifier(this._storage) : super([]) {
    _loadResources();
  }

  void _loadResources() {
    final data = _storage.getData(_storageKey);
    if (data != null) {
      final List<dynamic> list = data;
      state = list.map((e) => SocietyResource.fromJson(e)).toList();
    } else {
      // Initial mock resources
      state = [
        SocietyResource(
          id: const Uuid().v4(),
          orgId: MockData.orgId,
          title: 'Official GFG KIIT Logo',
          type: 'PNG',
          downloadUrl: 'mock_url_logo',
          uploadedBy: 'user-pres',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          sizeKb: 1250,
        ),
        SocietyResource(
          id: const Uuid().v4(),
          orgId: MockData.orgId,
          title: 'Event Management Guidelines',
          type: 'PDF',
          downloadUrl: 'mock_url_guidelines',
          uploadedBy: 'user-pres',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          sizeKb: 4500,
        ),
      ];
      _saveResources();
    }
  }

  void _saveResources() {
    _storage.saveData(_storageKey, state.map((e) => e.toJson()).toList());
  }

  void addResource(SocietyResource res) {
    state = [res, ...state];
    _saveResources();
  }

  void deleteResource(String id) {
    state = state.where((r) => r.id != id).toList();
    _saveResources();
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, List<SocietyResource>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return VaultNotifier(storage);
});
