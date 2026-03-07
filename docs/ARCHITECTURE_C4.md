# Architecture C4 - FoodFlow Pro (Enterprise Edition)

## 1. System Context Context
```mermaid
C4Context
    title System Context Diagram for FoodFlow Pro
    
    Person(customer, "Customer", "Uses mobile app to order food.")
    Person(courier, "Courier", "Uses mobile app to receive and deliver orders.")
    Person(restaurant, "Restaurant Staff", "Uses web dashboard to manage orders.")
    Person(admin, "System Admin", "Oversees system health and disputes.")

    System(foodflow, "FoodFlow Pro System", "Handles order dispatch, payments, and tracking.")

    System_Ext(stripe, "Stripe Connect", "Payment processing and payouts.")
    System_Ext(maps, "Google Maps Platform", "Geocoding, Routing, Matrix API.")
    System_Ext(algolia, "Algolia", "Geo-spatial search for restaurants.")
    System_Ext(sentry, "Sentry", "Error tracking and performance monitoring.")
    System_Ext(firebase_auth, "Firebase Auth", "Identity management.")

    Rel(customer, foodflow, "Places orders, tracks delivery", "HTTPS/WSS")
    Rel(courier, foodflow, "Accepts jobs, updates location", "HTTPS/WSS")
    Rel(restaurant, foodflow, "Manages menu, accepts orders", "HTTPS")
    Rel(admin, foodflow, "Administers system", "HTTPS")

    Rel(foodflow, stripe, "Charges customers, pays restaurants", "HTTPS")
    Rel(foodflow, maps, "Calculates ETAs and routes", "HTTPS")
    Rel(foodflow, algolia, "Indexes/Searches restaurants", "HTTPS")
    Rel(foodflow, sentry, "Sends telemetry", "HTTPS")
    Rel(foodflow, firebase_auth, "Authenticates users", "HTTPS")
```

## 2. Container Diagram
```mermaid
C4Container
    title Container Diagram for FoodFlow Pro

    Container(mobile_cust, "Customer App", "Flutter (Riverpod)", "Ordering interface.")
    Container(mobile_cour, "Courier App", "Flutter (Riverpod + Isar)", "Delivery interface. Offline-first.")
    Container(web_rest, "Restaurant Dashboard", "Flutter Web", "Order management.")
    Container(web_admin, "Admin Backoffice", "React/Next.js or Flutter Web", "System administration.")

    Container(api_gateway, "API Gateway / Cloud Functions", "Node.js (TypeScript)", "Business logic, Dispatcher, Payment triggers.")
    
    ContainerDb(firestore, "Primary Database", "Google Firestore", "NoSQL doc store. Real-time updates.")
    ContainerDb(redis, "Cache Layer", "Redis (Memorystore)", "Hot storage for Dispatch/Ranking.")
    ContainerDb(algolia_idx, "Search Index", "Algolia", "Restaurant catalog index.")

    Rel(mobile_cust, api_gateway, "API calls", "HTTPS")
    Rel(mobile_cust, firestore, "Real-time subscriptions", "WSS")
    
    Rel(mobile_cour, api_gateway, "API calls", "HTTPS")
    Rel(mobile_cour, firestore, "Real-time subscriptions", "WSS")

    Rel(api_gateway, firestore, "Reads/Writes", "SDK")
    Rel(api_gateway, redis, "Caches pricing/state", "TCP")
    Rel(api_gateway, algolia_idx, "Syncs data", "HTTPS")
```

## 3. Dynamic Dispatch Component (The "Brain")
```mermaid
C4Component
    title Component Diagram - Smart Dispatch System (Cloud Functions)

    Component(event_trigger, "Order Listener", "Cloud Function", "Triggered on order creation.")
    Component(geofence_svc, "Geofencing Service", "Module", "Determines active zones.")
    Component(matrix_svc, "Matrix API Service", "Module", "Calculates real travel times (not just radius).")
    Component(ranking_engine, "Courier Ranking Engine", "Module", "Scores couriers based on distance, rating, and batching potential.")
    Component(dispatch_tx, "Dispatch Transaction", "Firestore Transaction", "Atomically assigns order to courier pool.")

    Rel(event_trigger, geofence_svc, "1. Get Zone")
    Rel(event_trigger, matrix_svc, "2. Get ETAs for nearby couriers")
    Rel(event_trigger, ranking_engine, "3. Rank candidates")
    Rel(ranking_engine, dispatch_tx, "4. Create assignment offers")
```

## 4. Resilience & Security Patterns
- **Device Fingerprinting**: Capturing device hardware IDs on login to prevent fraud.
- **Offline-First (Courier)**: Isar database stores 'active job' locally. Syncs when network returns.
- **Idempotency**: All payment functions use idempotency keys to prevent double-charging.
- **Circuit Breaker**: If Google Maps API fails, fallback to simple Haversine distance calculation.
