import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../domain/models/task.dart';
import '../../../core/persistence/local_storage_service.dart';
import '../../../main.dart';

class TasksNotifier extends StateNotifier<List<SocietyTask>> {
  final LocalStorageService _storage;
  static const String _storageKey = 'society_tasks';

  TasksNotifier(this._storage) : super([]) {
    _loadTasks();
  }

  void _loadTasks() {
    final data = _storage.getData(_storageKey);
    if (data != null) {
      final List<dynamic> list = data;
      state = list.map((e) => SocietyTask.fromJson(e)).toList();
    } else {
      state = MockData.initialTasks;
      _saveTasks();
    }
  }

  void _saveTasks() {
    _storage.saveData(_storageKey, state.map((e) => e.toJson()).toList());
  }

  void addTask(SocietyTask task) {
    state = [...state, task];
    _saveTasks();
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    state = [
      for (final task in state)
        if (task.id == taskId) task.copyWith(status: newStatus) else task
    ];
    _saveTasks();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    _saveTasks();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<SocietyTask>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return TasksNotifier(storage);
});

final filteredTasksProvider = Provider.family<List<SocietyTask>, TaskStatus>((ref, status) {
  final allTasks = ref.watch(tasksProvider);
  return allTasks.where((task) => task.status == status).toList();
});
