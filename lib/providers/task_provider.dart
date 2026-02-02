import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  int _currentPage = 1;
  String? _statusFilter;
  String? _searchQuery;

  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = const AsyncValue.loading();
    }

    try {
      final tasks = await _repository.getTasks(
        page: _currentPage,
        status: _statusFilter,
        search: _searchQuery,
      );

      if (refresh || _currentPage == 1) {
        state = AsyncValue.data(tasks);
      } else {
        final currentTasks = state.value ?? [];
        state = AsyncValue.data([...currentTasks, ...tasks]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    
    _currentPage++;
    await loadTasks();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadTasks(refresh: true);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadTasks(refresh: true);
  }

  Future<void> createTask(String title, {String? description}) async {
    try {
      final newTask = await _repository.createTask(title, description: description);
      final currentTasks = state.value ?? [];
      state = AsyncValue.data([newTask, ...currentTasks]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateTask(String id, String title, {String? description}) async {
    try {
      final updatedTask = await _repository.updateTask(id, title, description: description);
      final currentTasks = state.value ?? [];
      final index = currentTasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        currentTasks[index] = updatedTask;
        state = AsyncValue.data([...currentTasks]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      final currentTasks = state.value ?? [];
      state = AsyncValue.data(
        currentTasks.where((task) => task.id != id).toList(),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> toggleTask(String id) async {
    try {
      final updatedTask = await _repository.toggleTask(id);
      final currentTasks = state.value ?? [];
      final index = currentTasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        currentTasks[index] = updatedTask;
        state = AsyncValue.data([...currentTasks]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
