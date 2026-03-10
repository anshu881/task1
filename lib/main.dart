import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/tasks/task_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    try {
      Firebase.app();
    } catch (_) {
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint('Firebase initialization skipped: $e');
      }
    }
  } catch (e) {
    debugPrint('Firebase setup error (ignored): $e');
  }
  
  runApp(
    const ProviderScope(
      child: TodoApp(),
    ),
  );
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'To-Do List App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TaskDashboardScreen(),
    );
  }
}
