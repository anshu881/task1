import '../models/task.dart';
import '../services/api_service.dart';

class TaskRepository {
  final ApiService _apiService = ApiService();

  Future<List<Task>> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    return await _apiService.getTasks(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }

  Future<Task> createTask(String title, {String? description}) async {
    return await _apiService.createTask(title, description: description);
  }

  Future<Task> updateTask(String id, String title, {String? description}) async {
    return await _apiService.updateTask(id, title, description: description);
  }

  Future<void> deleteTask(String id) async {
    return await _apiService.deleteTask(id);
  }

  Future<Task> toggleTask(String id) async {
    return await _apiService.toggleTask(id);
  }
}
