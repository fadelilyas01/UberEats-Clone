import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/firebase_restaurant_repository.dart';
import '../data/models.dart';

// Settings Provider (Set to false to use real Firebase data)
final useMockDataProvider = StateProvider<bool>((ref) => false);

// Placeholder for Firebase Implementation (Future)
class FirebaseAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async {
    // TODO: Implement Auth
    return null;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> signUpWithEmail(
      String name, String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }
}

// Dynamic Repositories based on settings
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  return useMock ? MockAuthRepository() : FirebaseAuthRepository();
});

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  return useMock ? MockRestaurantRepository() : FirebaseRestaurantRepository();
});

// Data Providers (Auto-dispose to refresh when repo changes)
final restaurantsProvider =
    FutureProvider.autoDispose<List<Restaurant>>((ref) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  return repo.getRestaurants();
});

final categoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  return repo.getCategories();
});

final restaurantDetailsProvider =
    FutureProvider.autoDispose.family<Restaurant?, String>((ref, id) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  return repo.getRestaurantById(id);
});

final restaurantMenuProvider =
    FutureProvider.autoDispose.family<List<MenuItem>, String>((ref, id) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  return repo.getMenuForRestaurant(id);
});

final currentUserProvider = FutureProvider.autoDispose<AppUser?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});
