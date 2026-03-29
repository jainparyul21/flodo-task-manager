import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';

// ── API Service ───────────────────────────────────────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// ── Search & Filter State ─────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<String>((ref) => 'All');

// ── Tasks Notifier ────────────────────────────────────────────────────────────
class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    final api = ref.read(apiServiceProvider);
    final search = ref.read(searchQueryProvider);
    final status = ref.read(statusFilterProvider);
    return api.getTasks(search: search, status: status);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTasks());
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    final api = ref.read(apiServiceProvider);
    final newTask = await api.createTask(data);
    state = state.whenData((tasks) => [...tasks, newTask]);
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    final api = ref.read(apiServiceProvider);
    final updated = await api.updateTask(id, data);
    state = state.whenData(
      (tasks) => tasks.map((t) => t.id == id ? updated : t).toList(),
    );
  }

  Future<void> deleteTask(int id) async {
    final api = ref.read(apiServiceProvider);
    await api.deleteTask(id);
    state = state.whenData((tasks) => tasks.where((t) => t.id != id).toList());
  }

  Future<void> reorder(List<Task> reordered) async {
    // Optimistically update UI
    state = AsyncData(reordered);
    final api = ref.read(apiServiceProvider);
    final items = reordered
        .asMap()
        .entries
        .map((e) => {'id': e.value.id, 'sort_order': e.key})
        .toList();
    await api.reorderTasks(items);
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);
