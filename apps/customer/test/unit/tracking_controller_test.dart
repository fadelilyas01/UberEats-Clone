import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the actual classes (adjust path as needed)
// For demonstration, we'll define simplified versions here

// Simplified TrackingState for test
class TrackingState {
  final String orderStatus;
  final double progress;
  final String eta;

  TrackingState({
    required this.orderStatus,
    required this.progress,
    required this.eta,
  });

  TrackingState copyWith({String? orderStatus, double? progress, String? eta}) {
    return TrackingState(
      orderStatus: orderStatus ?? this.orderStatus,
      progress: progress ?? this.progress,
      eta: eta ?? this.eta,
    );
  }
}

class TrackingController extends StateNotifier<TrackingState> {
  TrackingController()
      : super(TrackingState(
          orderStatus: 'confirmed',
          progress: 0.0,
          eta: '25 min',
        ));

  void startSimulation() {
    state = state.copyWith(orderStatus: 'preparing', eta: '20 min');
  }

  void pickUp() {
    state = state.copyWith(orderStatus: 'picked_up', eta: '15 min');
  }

  void updateProgress(double value) {
    final eta = '${(15 * (1 - value)).ceil()} min';
    state = state.copyWith(
      orderStatus: 'delivering',
      progress: value,
      eta: eta,
    );
  }

  void complete() {
    state = state.copyWith(
      orderStatus: 'delivered',
      progress: 1.0,
      eta: 'Arrived',
    );
  }
}

void main() {
  group('TrackingController Tests', () {
    late TrackingController controller;

    setUp(() {
      controller = TrackingController();
    });

    test('Initial state should be confirmed', () {
      expect(controller.state.orderStatus, 'confirmed');
      expect(controller.state.progress, 0.0);
      expect(controller.state.eta, '25 min');
    });

    test('startSimulation should change status to preparing', () {
      controller.startSimulation();

      expect(controller.state.orderStatus, 'preparing');
      expect(controller.state.eta, '20 min');
    });

    test('pickUp should change status to picked_up', () {
      controller.pickUp();

      expect(controller.state.orderStatus, 'picked_up');
      expect(controller.state.eta, '15 min');
    });

    test('updateProgress should update progress and ETA', () {
      controller.updateProgress(0.5);

      expect(controller.state.orderStatus, 'delivering');
      expect(controller.state.progress, 0.5);
      expect(controller.state.eta, '8 min'); // 15 * (1 - 0.5) = 7.5 -> ceil = 8
    });

    test('complete should set progress to 1 and status to delivered', () {
      controller.complete();

      expect(controller.state.orderStatus, 'delivered');
      expect(controller.state.progress, 1.0);
      expect(controller.state.eta, 'Arrived');
    });

    test('Full order lifecycle', () {
      // Initial
      expect(controller.state.orderStatus, 'confirmed');

      // Restaurant starts preparing
      controller.startSimulation();
      expect(controller.state.orderStatus, 'preparing');

      // Courier picks up
      controller.pickUp();
      expect(controller.state.orderStatus, 'picked_up');

      // Progress updates during delivery
      controller.updateProgress(0.25);
      expect(controller.state.progress, 0.25);

      controller.updateProgress(0.75);
      expect(controller.state.progress, 0.75);

      // Delivered
      controller.complete();
      expect(controller.state.orderStatus, 'delivered');
      expect(controller.state.progress, 1.0);
    });
  });

  group('Cart Logic Tests', () {
    test('Cart item total calculation', () {
      final item = CartItem(id: '1', name: 'Burger', price: 10.50, quantity: 2);
      expect(item.total, 21.0);
    });

    test('Cart item quantity update', () {
      final item = CartItem(id: '1', name: 'Burger', price: 10.50, quantity: 1);
      item.quantity = 3;
      expect(item.total, 31.5);
    });
  });
}

// Simple CartItem for testing
class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem(
      {required this.id,
      required this.name,
      required this.price,
      this.quantity = 1});

  double get total => price * quantity;
}
