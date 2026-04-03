import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task1/main.dart';
import 'package:task1/models/product.dart';
import 'package:task1/providers/app_providers.dart';

void main() {
  testWidgets('App loads and shows Orders tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsProvider.overrideWith((ref) async => const [
                Product(
                  id: 1,
                  name: 'Test product',
                  moq: 1,
                  dealerPrice: 10,
                  retailPrice: 12,
                ),
              ]),
        ],
        child: const InternalDemoApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('B2B orders'), findsOneWidget);
    expect(find.text('Test product'), findsOneWidget);
  });
}
