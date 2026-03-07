import 'models.dart';

/// Mock Categories
final mockCategories = [
  const Category(
      id: '1',
      name: 'Burgers',
      emoji: '🍔',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200'),
  const Category(
      id: '2',
      name: 'Pizza',
      emoji: '🍕',
      imageUrl:
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=200'),
  const Category(
      id: '3',
      name: 'Sushi',
      emoji: '🍣',
      imageUrl:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200'),
  const Category(
      id: '4',
      name: 'Salads',
      emoji: '🥗',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200'),
  const Category(
      id: '5',
      name: 'Asian',
      emoji: '🍜',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200'),
  const Category(
      id: '6',
      name: 'Mexican',
      emoji: '🌮',
      imageUrl:
          'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=200'),
  const Category(
      id: '7',
      name: 'Desserts',
      emoji: '🍰',
      imageUrl:
          'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=200'),
  const Category(
      id: '8',
      name: 'Drinks',
      emoji: '🥤',
      imageUrl:
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200'),
];

/// Mock Restaurants
final mockRestaurants = [
  const Restaurant(
    id: '1',
    name: 'Burger King Premium',
    description: 'Home of the Whopper. Flame-grilled perfection since 1954.',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
    coverUrl:
        'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=1200',
    rating: 4.8,
    reviewCount: 2453,
    deliveryTime: '15-25 min',
    deliveryFee: 'Free',
    tags: ['American', 'Burgers', 'Fast Food'],
    promo: '30% OFF',
    distance: 1.2,
  ),
  const Restaurant(
    id: '2',
    name: 'Sushi Master Tokyo',
    description: 'Authentic Japanese cuisine crafted by master chefs.',
    imageUrl:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600',
    coverUrl:
        'https://images.unsplash.com/photo-1553621042-f6e147245754?w=1200',
    rating: 4.9,
    reviewCount: 1876,
    deliveryTime: '30-45 min',
    deliveryFee: '€2.99',
    tags: ['Japanese', 'Sushi', 'Healthy'],
    distance: 2.5,
  ),
  const Restaurant(
    id: '3',
    name: 'Napoli Pizza House',
    description: 'Traditional Neapolitan pizza baked in a wood-fired oven.',
    imageUrl:
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600',
    coverUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200',
    rating: 4.7,
    reviewCount: 3241,
    deliveryTime: '20-35 min',
    deliveryFee: 'Free',
    tags: ['Italian', 'Pizza', 'Pasta'],
    promo: '20% OFF',
    distance: 0.8,
  ),
  const Restaurant(
    id: '4',
    name: 'Thai Express Gourmet',
    description: 'Authentic Thai street food with a modern twist.',
    imageUrl: 'https://images.unsplash.com/photo-1562565652-a0d8f0c59eb4?w=600',
    coverUrl:
        'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=1200',
    rating: 4.6,
    reviewCount: 987,
    deliveryTime: '25-40 min',
    deliveryFee: '€1.99',
    tags: ['Thai', 'Asian', 'Spicy'],
    distance: 1.8,
  ),
  const Restaurant(
    id: '5',
    name: 'Green Garden Salads',
    description: 'Fresh, organic, and delicious healthy bowls.',
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
    coverUrl:
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=1200',
    rating: 4.5,
    reviewCount: 654,
    deliveryTime: '15-25 min',
    deliveryFee: '€1.49',
    tags: ['Healthy', 'Salads', 'Vegan'],
    promo: 'NEW',
    distance: 0.5,
  ),
  const Restaurant(
    id: '6',
    name: 'El Mexicano Cantina',
    description: 'Authentic Mexican flavors with fresh ingredients.',
    imageUrl:
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600',
    coverUrl:
        'https://images.unsplash.com/photo-1552332386-f8dd00dc2f85?w=1200',
    rating: 4.4,
    reviewCount: 1123,
    deliveryTime: '20-30 min',
    deliveryFee: 'Free',
    tags: ['Mexican', 'Tacos', 'Burritos'],
    distance: 1.5,
  ),
];

/// Mock Menu Items per Restaurant
final mockMenuItems = {
  '1': [
    const MenuItem(
        id: 'm1',
        restaurantId: '1',
        name: 'Double Whopper Cheese',
        description:
            'Two flame-grilled beef patties, American cheese, fresh lettuce, tomatoes, onions, pickles and mayo',
        price: 12.50,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        category: 'Burgers',
        isPopular: true),
    const MenuItem(
        id: 'm2',
        restaurantId: '1',
        name: 'Chicken Royale Deluxe',
        description:
            'Crispy chicken fillet with special sauce, fresh lettuce and creamy mayo',
        price: 10.90,
        imageUrl:
            'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400',
        category: 'Burgers',
        isPopular: true),
    const MenuItem(
        id: 'm3',
        restaurantId: '1',
        name: 'Veggie Whopper',
        description:
            'Plant-based patty with fresh vegetables and signature flame-grilled taste',
        price: 11.50,
        imageUrl:
            'https://images.unsplash.com/photo-1520072959219-c595dc870360?w=400',
        category: 'Burgers',
        isVegetarian: true),
    const MenuItem(
        id: 'm4',
        restaurantId: '1',
        name: 'Loaded Cheese Fries',
        description:
            'Golden crispy fries topped with melted cheddar, bacon bits and jalapeños',
        price: 6.50,
        imageUrl:
            'https://images.unsplash.com/photo-1630384060421-cb20aac1debd?w=400',
        category: 'Sides',
        isPopular: true),
    const MenuItem(
        id: 'm5',
        restaurantId: '1',
        name: 'Onion Rings',
        description:
            'Crispy battered onion rings served with BBQ dipping sauce',
        price: 4.90,
        imageUrl:
            'https://images.unsplash.com/photo-1639024471283-03518883512d?w=400',
        category: 'Sides'),
    const MenuItem(
        id: 'm6',
        restaurantId: '1',
        name: 'Oreo Milkshake',
        description: 'Creamy vanilla shake blended with crushed Oreo cookies',
        price: 5.90,
        imageUrl:
            'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400',
        category: 'Drinks'),
    const MenuItem(
        id: 'm7',
        restaurantId: '1',
        name: 'Chocolate Sundae',
        description: 'Soft-serve vanilla ice cream with rich chocolate sauce',
        price: 3.90,
        imageUrl:
            'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
        category: 'Desserts'),
  ],
  '2': [
    const MenuItem(
        id: 's1',
        restaurantId: '2',
        name: 'Dragon Roll Deluxe',
        description:
            'Shrimp tempura, avocado, cucumber, topped with eel and special sauce',
        price: 18.90,
        imageUrl:
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
        category: 'Rolls',
        isPopular: true),
    const MenuItem(
        id: 's2',
        restaurantId: '2',
        name: 'Rainbow Roll',
        description: 'California roll topped with assorted fresh sashimi',
        price: 16.50,
        imageUrl:
            'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=400',
        category: 'Rolls',
        isPopular: true),
    const MenuItem(
        id: 's3',
        restaurantId: '2',
        name: 'Salmon Nigiri (6pc)',
        description: 'Fresh Atlantic salmon over seasoned sushi rice',
        price: 14.90,
        imageUrl:
            'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=400',
        category: 'Nigiri'),
    const MenuItem(
        id: 's4',
        restaurantId: '2',
        name: 'Edamame',
        description: 'Steamed soybeans with sea salt',
        price: 5.50,
        imageUrl:
            'https://images.unsplash.com/photo-1564894809611-1742fc40ed80?w=400',
        category: 'Starters',
        isVegetarian: true),
    const MenuItem(
        id: 's5',
        restaurantId: '2',
        name: 'Miso Soup',
        description:
            'Traditional Japanese soup with tofu, seaweed and green onions',
        price: 4.50,
        imageUrl:
            'https://images.unsplash.com/photo-1607301406259-dfb186e15de8?w=400',
        category: 'Soups',
        isVegetarian: true),
  ],
  '3': [
    const MenuItem(
        id: 'p1',
        restaurantId: '3',
        name: 'Margherita DOC',
        description:
            'San Marzano tomatoes, fresh mozzarella, basil, extra virgin olive oil',
        price: 14.50,
        imageUrl:
            'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
        category: 'Pizza',
        isPopular: true,
        isVegetarian: true),
    const MenuItem(
        id: 'p2',
        restaurantId: '3',
        name: 'Pepperoni Feast',
        description: 'Double pepperoni, mozzarella, spicy Calabrian chili',
        price: 16.90,
        imageUrl:
            'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
        category: 'Pizza',
        isPopular: true),
    const MenuItem(
        id: 'p3',
        restaurantId: '3',
        name: 'Quattro Formaggi',
        description: 'Mozzarella, gorgonzola, parmesan, ricotta cheese blend',
        price: 17.50,
        imageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
        category: 'Pizza',
        isVegetarian: true),
    const MenuItem(
        id: 'p4',
        restaurantId: '3',
        name: 'Tiramisu',
        description: 'Classic Italian dessert with mascarpone and espresso',
        price: 7.90,
        imageUrl:
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
        category: 'Desserts',
        isPopular: true),
  ],
};

/// Get menu items for a restaurant
List<MenuItem> getMenuForRestaurant(String restaurantId) {
  return mockMenuItems[restaurantId] ?? [];
}

/// Get restaurant by ID
Restaurant? getRestaurantById(String id) {
  try {
    return mockRestaurants.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
}
