import 'dart:convert';

/// Restaurant Model
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String coverUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final List<String> tags;
  final String? promo;
  final bool isFavorite;
  final double distance;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.coverUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.tags,
    this.promo,
    this.isFavorite = false,
    this.distance = 0,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? coverUrl,
    double? rating,
    int? reviewCount,
    String? deliveryTime,
    String? deliveryFee,
    List<String>? tags,
    String? promo,
    bool? isFavorite,
    double? distance,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tags: tags ?? this.tags,
      promo: promo ?? this.promo,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverUrl': coverUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'tags': tags,
      'promo': promo,
      'isFavorite': isFavorite,
      'distance': distance,
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map, {String? id}) {
    return Restaurant(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount']?.toInt() ?? 0,
      deliveryTime: map['deliveryTime'] ?? '',
      deliveryFee: map['deliveryFee'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      promo: map['promo'],
      isFavorite: map['isFavorite'] ?? false,
      distance: (map['distance'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Restaurant.fromJson(String source) =>
      Restaurant.fromMap(json.decode(source));
}

/// Menu Item Model
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isPopular;
  final bool isVegetarian;
  final List<String> allergens;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isPopular = false,
    this.isVegetarian = false,
    this.allergens = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isPopular': isPopular,
      'isVegetarian': isVegetarian,
      'allergens': allergens,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return MenuItem(
      id: id ?? map['id'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isPopular: map['isPopular'] ?? false,
      isVegetarian: map['isVegetarian'] ?? false,
      allergens: List<String>.from(map['allergens'] ?? []),
    );
  }
}

/// Cart Item Model
class CartItem {
  final MenuItem item;
  int quantity;
  final String? specialInstructions;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get total => item.price * quantity;

  CartItem copyWith({int? quantity, String? specialInstructions}) => CartItem(
        item: item,
        quantity: quantity ?? this.quantity,
        specialInstructions: specialInstructions ?? this.specialInstructions,
      );

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      item: MenuItem.fromMap(map['item']),
      quantity: map['quantity']?.toInt() ?? 1,
      specialInstructions: map['specialInstructions'],
    );
  }
}

/// User Model
class AppUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phone;
  final List<Address> addresses;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phone,
    this.addresses = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'addresses': addresses.map((x) => x.toMap()).toList(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      addresses: List<Address>.from(
          (map['addresses'] ?? []).map((x) => Address.fromMap(x))),
    );
  }
}

/// Address Model
class Address {
  final String id;
  final String label;
  final String street;
  final String city;
  final String postalCode;
  final String? instructions;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.postalCode,
    this.instructions,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'instructions': instructions,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      instructions: map['instructions'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}

/// Order Model
class Order {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final Address deliveryAddress;
  final String? courierId;
  final String? courierName;

  const Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    this.courierId,
    this.courierName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'deliveryAddress': deliveryAddress.toMap(),
      'courierId': courierId,
      'courierName': courierName,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      items: List<CartItem>.from(
          (map['items'] ?? []).map((x) => CartItem.fromMap(x))),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      serviceFee: (map['serviceFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      deliveryAddress: Address.fromMap(map['deliveryAddress']),
      courierId: map['courierId'],
      courierName: map['courierName'],
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  pickedUp,
  delivering,
  delivered,
  cancelled,
}

/// Category Model
class Category {
  final String id;
  final String name;
  final String emoji;
  final String imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'imageUrl': imageUrl,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
