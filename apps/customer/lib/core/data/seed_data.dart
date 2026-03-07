import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedData() async {
    print('Starting database seeding...');

    // 1. Catégories
    final categories = [
      const Category(
          id: 'burgers',
          name: 'Burgers',
          emoji: '🍔',
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/foodflow-5c2cb.appspot.com/o/categories%2Fburger.png?alt=media'),
      const Category(
          id: 'pizza',
          name: 'Pizza',
          emoji: '🍕',
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/foodflow-5c2cb.appspot.com/o/categories%2Fpizza.png?alt=media'),
      const Category(
          id: 'asian',
          name: 'Asiatique',
          emoji: '🍜',
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/foodflow-5c2cb.appspot.com/o/categories%2Fasian.png?alt=media'),
      const Category(
          id: 'mexican',
          name: 'Mexicain',
          emoji: '🌮',
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/foodflow-5c2cb.appspot.com/o/categories%2Fmexican.png?alt=media'),
      const Category(
          id: 'healthy',
          name: 'Santé',
          emoji: '🥗',
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/foodflow-5c2cb.appspot.com/o/categories%2Fhealthy.png?alt=media'),
      const Category(
          id: 'dessert',
          name: 'Dessert',
          emoji: '🍦',
          imageUrl:
              'https://firebasestorage.googleapis.com/v0/b/foodflow-5c2cb.appspot.com/o/categories%2Fdessert.png?alt=media'),
    ];

    for (var cat in categories) {
      await _firestore.collection('categories').doc(cat.id).set(cat.toMap());
      print('Catégorie ajoutée: ${cat.name}');
    }

    // 2. Restaurants
    final restaurants = [
      Restaurant(
        id: 'rest_1',
        name: 'Burger King Premium',
        description: 'Les meilleurs burgers grillés à la flamme en ville.',
        imageUrl:
            'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800',
        coverUrl:
            'https://images.unsplash.com/photo-1550547660-d9450f859349?w=1200',
        rating: 4.8,
        reviewCount: 1240,
        deliveryTime: '25-35 min',
        deliveryFee: '2,99 \$',
        tags: ['Burgers', 'Américain', 'Fast Food'],
        promo: 'Livraison Gratuite',
        isFavorite: false,
        distance: 2.1,
      ),
      Restaurant(
        id: 'rest_2',
        name: 'Sushi Master',
        description: 'Sushis et sashimis japonais authentiques.',
        imageUrl:
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800',
        coverUrl:
            'https://images.unsplash.com/photo-1553621042-f6e147245754?w=1200',
        rating: 4.9,
        reviewCount: 850,
        deliveryTime: '40-50 min',
        deliveryFee: '4,99 \$',
        tags: ['Asiatique', 'Sushi', 'Japonais'],
        isFavorite: true,
        distance: 4.5,
      ),
      Restaurant(
        id: 'rest_3',
        name: 'La Pizza Nostra',
        description: 'Pizzas italiennes traditionnelles au feu de bois.',
        imageUrl:
            'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=800',
        coverUrl:
            'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=1200',
        rating: 4.7,
        reviewCount: 520,
        deliveryTime: '30-40 min',
        deliveryFee: '3,49 \$',
        tags: ['Pizza', 'Italien'],
        distance: 3.2,
      ),
      Restaurant(
        id: 'rest_4',
        name: 'Green Bowl',
        description: 'Salades saines et bols biologiques.',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
        coverUrl:
            'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=1200',
        rating: 4.6,
        reviewCount: 320,
        deliveryTime: '20-30 min',
        deliveryFee: '1,99 \$',
        tags: ['Santé', 'Vegan', 'Salade'],
        promo: '15% DE RABAIS',
        distance: 1.5,
      ),
    ];

    for (var rest in restaurants) {
      await _firestore.collection('restaurants').doc(rest.id).set(rest.toMap());
      print('Added restaurant: ${rest.name}');

      // Add dummy menu items for this restaurant
      await _seedMenu(rest.id);
    }

    print('Database seeding completed successfully! 🚀');
  }

  Future<void> _seedMenu(String restaurantId) async {
    final menuItems = [
      MenuItem(
        id: 'item_${restaurantId}_1',
        restaurantId: restaurantId,
        name: 'Cheeseburger Classique',
        description:
            'Bœuf juteux, cheddar fondant, laitue et tomate.',
        price: 12.99,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        category: 'Burgers',
        isPopular: true,
      ),
      MenuItem(
        id: 'item_${restaurantId}_2',
        restaurantId: restaurantId,
        name: 'Burger Double Bacon',
        description: 'Double boulette de bœuf, bacon croustillant et sauce BBQ.',
        price: 15.49,
        imageUrl:
            'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=500',
        category: 'Burgers',
      ),
      MenuItem(
        id: 'item_${restaurantId}_3',
        restaurantId: restaurantId,
        name: 'Wrap Poulet Épicé',
        description: 'Poulet grillé avec mayo épicée et légumes frais.',
        price: 9.99,
        imageUrl:
            'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500',
        category: 'Wraps',
        isPopular: true,
      ),
    ];

    final batch = _firestore.batch();
    for (var item in menuItems) {
      final docRef = _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu_items')
          .doc(item.id);
      batch.set(docRef, item.toMap());
    }
    await batch.commit();
    print('Added menu for restaurant: $restaurantId');
  }
}
