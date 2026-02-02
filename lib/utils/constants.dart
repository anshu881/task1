class ApiConstants {
  // Update this with your backend API base URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  
  // Task endpoints
  static const String tasksEndpoint = '/tasks';
  static String taskByIdEndpoint(String id) => '/tasks/$id';
  static String toggleTaskEndpoint(String id) => '/tasks/$id/toggle';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}
