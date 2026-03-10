import '../models/task.dart';
import '../services/firebase_database_service.dart';

class TaskRepository {
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  Future<List<Task>> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    List<Task> tasks = await _databaseService.getTasks();

    // Apply search filter
    if (search != null && search.isNotEmpty) {
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(search.toLowerCase()) ||
            (task.description?.toLowerCase().contains(search.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply status filter
    if (status != null && status.isNotEmpty) {
      if (status == 'completed') {
        tasks = tasks.where((task) => task.completed).toList();
      } else if (status == 'pending') {
        tasks = tasks.where((task) => !task.completed).toList();
      }
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    if (startIndex >= tasks.length) {
      return [];
    }
    return tasks.sublist(
      startIndex,
      endIndex > tasks.length ? tasks.length : endIndex,
    );
  }

  Future<Task> createTask(String title, {String? description}) async {
    return await _databaseService.createTask(title, description: description);
  }

  Future<Task> updateTask(String id, String title, {String? description}) async {
    return await _databaseService.updateTask(id, title, description: description);
  }

  Future<void> deleteTask(String id) async {
    return await _databaseService.deleteTask(id);
  }

  Future<Task> toggleTask(String id) async {
    return await _databaseService.toggleTask(id);
  }

  // Get all tasks without pagination (for filtering/searching)
  Future<List<Task>> getAllTasks() async {
    return await _databaseService.getTasks();
  }
}
