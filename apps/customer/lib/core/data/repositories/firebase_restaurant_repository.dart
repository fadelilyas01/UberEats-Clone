import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';
import 'restaurant_repository.dart';

class FirebaseRestaurantRepository implements RestaurantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      return snapshot.docs
          .map((doc) => Restaurant.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();
      if (!doc.exists) return null;
      return Restaurant.fromMap(doc.data()!, id: doc.id);
    } catch (e) {
      print('Error fetching restaurant: $e');
      return null;
    }
  }

  @override
  Future<List<MenuItem>> getMenuForRestaurant(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu_items')
          .get();
      return snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      print('Error fetching menu: $e');
      return [];
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Inject ID into map for fromMap
        return Category.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}
