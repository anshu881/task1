import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../utils/firebase_constants.dart';
import 'firebase_auth_service.dart';

class FirebaseDatabaseService {
  final FirebaseAuthService _authService = FirebaseAuthService();

  String get _userId {
    try {
      return _authService.currentUser?.uid ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<String?> _getIdToken() async {
    try {
      return await _authService.currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final idToken = await _getIdToken();
    if (idToken == null) {
      throw Exception('User not authenticated or Firebase not initialized');
    }

    final url = Uri.parse('${FirebaseConstants.databaseUrl}$path?auth=$idToken');
    
    http.Response response;
    final headers = {'Content-Type': 'application/json'};

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Firebase API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final data = await _makeRequest('GET', FirebaseConstants.tasksPath(_userId));
      
      if (data.isEmpty || data['null'] != null) {
        return [];
      }

      final List<Task> tasks = [];
      data.forEach((key, value) {
        if (value != null) {
          tasks.add(Task.fromFirebaseJson(key, value as Map<String, dynamic>));
        }
      });

      // Sort by createdAt (newest first)
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw Exception('Failed to fetch tasks: ${e.toString()}');
    }
  }

  Future<Task> createTask(String title, {String? description}) async {
    try {
      final taskData = {
        'title': title,
        'description': description ?? '',
        'completed': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await _makeRequest(
        'POST',
        FirebaseConstants.tasksPath(_userId),
        body: taskData,
      );

      final taskId = response['name'] as String;
      return Task.fromFirebaseJson(taskId, taskData);
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  Future<Task> updateTask(String id, String title, {String? description}) async {
    try {
      final taskData = {
        'title': title,
        'description': description ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _makeRequest(
        'PATCH',
        FirebaseConstants.taskPath(_userId, id),
        body: taskData,
      );

      // Fetch updated task
      final allTasks = await getTasks();
      return allTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _makeRequest('DELETE', FirebaseConstants.taskPath(_userId, id));
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  Future<Task> toggleTask(String id) async {
    try {
      // First get the current task
      final allTasks = await getTasks();
      final task = allTasks.firstWhere((task) => task.id == id);

      final taskData = {
        'completed': !task.completed,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _makeRequest(
        'PATCH',
        FirebaseConstants.taskPath(_userId, id),
        body: taskData,
      );

      return task.copyWith(
        completed: !task.completed,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to toggle task: ${e.toString()}');
    }
  }
}
