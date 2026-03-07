
// MOCK IMPLEMENTATION FOR BUILD TROUBLESHOOTING
// To enable real Firestore, uncomment cloud_firestore in pubspec.yaml and restore this file

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== COURIER DATA MODELS (Simplified) =====

class CourierProfile {
  final String id;
  final String name;
  final String email;
  final double rating;
  final bool isOnline;

  CourierProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.isOnline,
  });
}

class DeliveryOffer {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final double earnings;
  final double distanceKm;
  final List<Map<String, dynamic>> items;

  DeliveryOffer({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.earnings,
    required this.distanceKm,
    required this.items,
  });
}

class ActiveDelivery {
  final String id;
  final String status;
  final String restaurantName;
  final String restaurantAddress;
  final String customerName;
  final String customerAddress;
  final double earnings;

  ActiveDelivery({
    required this.id,
    required this.status,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerName,
    required this.customerAddress,
    required this.earnings,
  });
}

// ===== COURIER REPOSITORY (Mock) =====

final courierRepositoryProvider = Provider((ref) => CourierRepository());

class CourierRepository {
  CourierRepository();

  Stream<CourierProfile?> getCourierProfile(String courierId) {
    return Stream.value(CourierProfile(
      id: 'mock-id',
      name: 'John Doe (Mock)',
      email: 'john@example.com',
      rating: 4.9,
      isOnline: true,
    ));
  }

  Future<void> setOnlineStatus(String courierId, bool isOnline) async {
    // Mock implementation
  }

  Future<void> updateLocation(String courierId, dynamic location) async {
    // Mock implementation
  }

  Stream<List<DeliveryOffer>> getPendingOffers(String courierId) {
    return Stream.value([]);
  }

  Future<void> acceptOffer(String offerId, String courierId) async {
    // Mock implementation
  }

  Future<void> declineOffer(String offerId) async {
    // Mock implementation
  }

  Stream<ActiveDelivery?> getActiveDelivery(String courierId) {
    return Stream.value(null);
  }

  Future<void> updateDeliveryStatus(String deliveryId, String newStatus) async {
    // Mock implementation
  }

  Stream<List<ActiveDelivery>> getDeliveryHistory(String courierId) {
    return Stream.value([]);
  }
}
