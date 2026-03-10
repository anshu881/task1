class FirebaseConstants {
  // Replace with your Firebase Realtime Database URL
  // Format: https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com
  static const String databaseUrl = 'YOUR_FIREBASE_DATABASE_URL';
  
  // Firebase REST API endpoints
  static String tasksPath(String userId) => '/users/$userId/tasks.json';
  static String taskPath(String userId, String taskId) => '/users/$userId/tasks/$taskId.json';
}
