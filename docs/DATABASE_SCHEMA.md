# Data Model - FoodFlow Pro

## Overview
FoodFlow Pro uses a **hybrid data strategy**:
1. **Firestore**: The single source of truth for the entire system (Online).
2. **Isar**: Local, highly performant NoSQL database for the Courier App (Offline support).
3. **Redis**: Ephemeral state for the "Silent Auction" dispatch system.

## Firestore Schema (Dénormalisé pour la lecture)

### 1. `users` Collection
Stores Customers, Couriers, and Restaurant Managers.
```json
{
  "uid": "string (Firebase Auth via Phone)",
  "role": "customer | courier | manager | admin",
  "profile": {
    "name": "string",
    "email": "string",
    "avatar_url": "string"
  },
  "settings": {
    "language": "en | fr",
    "notifications_enabled": true
  },
  // Specific to Courier
  "courier_meta": {
    "status": "offline | online | busy",
    "current_location": { "geohash": "string", "lat": 1.0, "lng": 1.0 },
    "vehicle_type": "bike | car",
    "score": 4.85,
    "active_order_id": null
  },
  "security_fingerprint": "hash_of_device_id"
}
```

### 2. `orders` Collection
High-traffic collection. Read-heavy.
```json
{
  "id": "order_xyz",
  "status": "pending | cooking | picking_up | delivering | delivered | cancelled",
  "customer_id": "uid_123",
  "restaurant_id": "rest_456",
  "courier_id": "cour_789 (assigned later)",
  "items": [
    { "item_id": "p1", "name": "Burger", "qty": 2, "price": 1200, "options": [] }
  ],
  "financials": {
    "subtotal": 2400,
    "tax": 200,
    "delivery_fee": 300,
    "platform_fee": 150,
    "total": 3050,
    "currency": "eur",
    "stripe_payment_intent": "pi_..."
  },
  "logistics": {
    "pickup_geo": { "lat": 1.0, "lng": 1.0 },
    "dropoff_geo": { "lat": 1.1, "lng": 1.1 },
    "distance_meters": 1500,
    "estimated_prep_time_min": 15
  },
  "timestamps": {
    "created_at": "Timestamp",
    "accepted_at": "Timestamp",
    "delivered_at": "Timestamp"
  }
}
```

### 3. `audit_logs` Collection
Immutable record of important actions.
```json
{
  "id": "auto-gen",
  "actor_id": "uid",
  "action": "order_cancelled | refund_processed",
  "target_id": "order_xyz",
  "meta": { "reason": "No capacity" },
  "timestamp": "Timestamp"
}
```

### 4. `geofenced_zones`
Configuration for operational zones.
```json
{
  "id": "paris_zone_1",
  "name": "Paris Center",
  "isActive": true,
  "polygon": [ { "lat": 1, "lng": 1 }, ... ],
  "pricing_multipliers": {
    "rain": 1.2,
    "rush_hour": 1.5
  }
}
```

## Isar Schema (Local - Courier App)
The Courier app mirrors active orders locally to survive dead zones (elevators, basements).
```dart
@collection
class LocalOrder {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String firestoreId;

  late String status; // Synced from Firestore
  late String customerName;
  late String dropoffAddress;
  
  // Stored strictly locally until synced
  late bool isDeliveredOffline; 
  late DateTime? deliveredAt;
}
```
