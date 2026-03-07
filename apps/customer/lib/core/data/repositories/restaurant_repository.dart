import '../models.dart';
import '../mock_data.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<Restaurant?> getRestaurantById(String id);
  Future<List<MenuItem>> getMenuForRestaurant(String restaurantId);
  Future<List<Category>> getCategories();
}

class MockRestaurantRepository implements RestaurantRepository {
  @override
  Future<List<Restaurant>> getRestaurants() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return mockRestaurants;
  }

  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return mockRestaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MenuItem>> getMenuForRestaurant(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Check if the map contains the key directly
    return mockMenuItems[restaurantId] ?? [];
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockCategories;
  }
}
