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
      // For Firebase, we get all tasks and filter client-side
      // This is more efficient for real-time updates
      final allTasks = await _repository.getAllTasks();
      
      // Apply filters
      List<Task> filteredTasks = allTasks;
      
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        filteredTasks = filteredTasks.where((task) {
          return task.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              (task.description?.toLowerCase().contains(_searchQuery!.toLowerCase()) ?? false);
        }).toList();
      }
      
      if (_statusFilter != null && _statusFilter!.isNotEmpty) {
        if (_statusFilter == 'completed') {
          filteredTasks = filteredTasks.where((task) => task.completed).toList();
        } else if (_statusFilter == 'pending') {
          filteredTasks = filteredTasks.where((task) => !task.completed).toList();
        }
      }
      
      // Apply pagination
      final startIndex = (_currentPage - 1) * 10;
      final endIndex = startIndex + 10;
      final paginatedTasks = endIndex > filteredTasks.length
          ? filteredTasks.sublist(startIndex)
          : filteredTasks.sublist(startIndex, endIndex);

      if (refresh || _currentPage == 1) {
        state = AsyncValue.data(filteredTasks);
      } else {
        final currentTasks = state.value ?? [];
        state = AsyncValue.data([...currentTasks, ...paginatedTasks]);
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
