import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';

/// Cart State
class CartState {
  final String? restaurantId;
  final String? restaurantName;
  final List<CartItem> items;

  const CartState({
    this.restaurantId,
    this.restaurantName,
    this.items = const [],
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get deliveryFee => subtotal > 30 ? 0 : 2.99;
  double get serviceFee => subtotal * 0.05;
  double get total => subtotal + deliveryFee + serviceFee;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    String? restaurantId,
    String? restaurantName,
    List<CartItem>? items,
  }) =>
      CartState(
        restaurantId: restaurantId ?? this.restaurantId,
        restaurantName: restaurantName ?? this.restaurantName,
        items: items ?? this.items,
      );
}

/// Cart Notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Add item to cart
  void addItem(MenuItem item, String restaurantId, String restaurantName,
      {int quantity = 1}) {
    // If cart has items from different restaurant, clear first
    if (state.restaurantId != null && state.restaurantId != restaurantId) {
      state =
          CartState(restaurantId: restaurantId, restaurantName: restaurantName);
    }

    final existingIndex = state.items.indexWhere((i) => i.item.id == item.id);

    if (existingIndex >= 0) {
      // Update quantity
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      state = state.copyWith(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: [...state.items, CartItem(item: item, quantity: quantity)],
      );
    }
  }

  /// Remove item from cart
  void removeItem(String itemId) {
    final updatedItems = state.items.where((i) => i.item.id != itemId).toList();
    if (updatedItems.isEmpty) {
      state = const CartState();
    } else {
      state = state.copyWith(items: updatedItems);
    }
  }

  /// Update item quantity
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  /// Increment item quantity
  void incrementItem(String itemId) {
    final item = state.items.firstWhere((i) => i.item.id == itemId);
    updateQuantity(itemId, item.quantity + 1);
  }

  /// Decrement item quantity
  void decrementItem(String itemId) {
    final item = state.items.firstWhere((i) => i.item.id == itemId);
    updateQuantity(itemId, item.quantity - 1);
  }

  /// Clear cart
  void clearCart() {
    state = const CartState();
  }

  /// Get quantity for a specific item
  int getQuantity(String itemId) {
    try {
      return state.items.firstWhere((i) => i.item.id == itemId).quantity;
    } catch (_) {
      return 0;
    }
  }
}

/// Cart Provider
final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());

/// Derived providers for convenience
final cartItemCountProvider =
    Provider<int>((ref) => ref.watch(cartProvider).itemCount);
final cartTotalProvider =
    Provider<double>((ref) => ref.watch(cartProvider).total);
final cartIsEmptyProvider =
    Provider<bool>((ref) => ref.watch(cartProvider).isEmpty);
