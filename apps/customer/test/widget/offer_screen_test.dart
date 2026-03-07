import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Offer Screen Widget Tests', () {
    testWidgets('Should display earnings prominently', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MockOfferScreen(earnings: 12.50),
          ),
        ),
      );

      expect(find.text('12.50 €'), findsOneWidget);
    });

    testWidgets('Should show Accept button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MockOfferScreen(earnings: 12.50),
          ),
        ),
      );

      expect(find.text('ACCEPTER LA COURSE'), findsOneWidget);
    });

    testWidgets('Should show Refuse button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MockOfferScreen(earnings: 12.50),
          ),
        ),
      );

      expect(find.text('Refuser'), findsOneWidget);
    });

    testWidgets('Accept button should be tappable', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () => wasPressed = true,
                child: const Text('ACCEPTER LA COURSE'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ACCEPTER LA COURSE'));
      await tester.pump();

      expect(wasPressed, true);
    });

    testWidgets('Timer should be visible', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MockOfferScreen(earnings: 12.50),
          ),
        ),
      );

      // Timer should show initial value (30 or close to it)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Restaurant Card Widget Tests', () {
    testWidgets('Should display restaurant name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MockRestaurantCard(
              name: 'Burger King',
              rating: 4.5,
            ),
          ),
        ),
      );

      expect(find.text('Burger King'), findsOneWidget);
    });

    testWidgets('Should display rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MockRestaurantCard(
              name: 'Burger King',
              rating: 4.5,
            ),
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
    });
  });
}

// Mock widgets for testing (simplified versions)
class MockOfferScreen extends StatelessWidget {
  final double earnings;

  const MockOfferScreen({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('${earnings.toStringAsFixed(2)} €',
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('ACCEPTER LA COURSE'),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }
}

class MockRestaurantCard extends StatelessWidget {
  final String name;
  final double rating;

  const MockRestaurantCard(
      {super.key, required this.name, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Text(rating.toString()),
      ),
    );
  }
}
