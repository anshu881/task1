import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    return headers;
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: includeAuth);

    http.Response response;

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
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Handle token refresh if access token expired
    if (response.statusCode == 401 && includeAuth) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the request with new token
        return _makeRequest(method, endpoint, body: body, includeAuth: includeAuth);
      }
    }

    return response;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _makeRequest(
        'POST',
        ApiConstants.refreshEndpoint,
        body: {'refreshToken': refreshToken},
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.saveAccessToken(data['accessToken'] as String);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await _makeRequest(
      'POST',
      ApiConstants.registerEndpoint,
      body: {
        'email': email,
        'password': password,
        'name': name,
      },
      includeAuth: false,
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      await _storageService.saveAccessToken(data['accessToken'] as String);
      await _storageService.saveRefreshToken(data['refreshToken'] as String);
      return {'success': true, 'user': User.fromJson(data['user'])};
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _makeRequest(
      'POST',
      ApiConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      includeAuth: false,
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      await _storageService.saveAccessToken(data['accessToken'] as String);
      await _storageService.saveRefreshToken(data['refreshToken'] as String);
      return {'success': true, 'user': User.fromJson(data['user'])};
    }

    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<void> logout() async {
    try {
      await _makeRequest('POST', ApiConstants.logoutEndpoint);
    } finally {
      await _storageService.clearTokens();
    }
  }

  // Task methods
  Future<List<Task>> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final response = await _makeRequest(
      'GET',
      '${ApiConstants.tasksEndpoint}?$queryString',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> tasksJson = data['tasks'] ?? data;
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    }

    throw Exception('Failed to load tasks');
  }

  Future<Task> createTask(String title, {String? description}) async {
    final response = await _makeRequest(
      'POST',
      ApiConstants.tasksEndpoint,
      body: {
        'title': title,
        'description': description,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data);
    }

    throw Exception('Failed to create task');
  }

  Future<Task> updateTask(String id, String title, {String? description}) async {
    final response = await _makeRequest(
      'PATCH',
      ApiConstants.taskByIdEndpoint(id),
      body: {
        'title': title,
        'description': description,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data);
    }

    throw Exception('Failed to update task');
  }

  Future<void> deleteTask(String id) async {
    final response = await _makeRequest(
      'DELETE',
      ApiConstants.taskByIdEndpoint(id),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  Future<Task> toggleTask(String id) async {
    final response = await _makeRequest(
      'PATCH',
      ApiConstants.toggleTaskEndpoint(id),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data);
    }

    throw Exception('Failed to toggle task');
  }
}
