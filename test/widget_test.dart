// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task1/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: TodoApp(),
      ),
    );

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that login screen is shown (check for "Task Management" or "Sign in" text)
    expect(find.text('Task Management'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
