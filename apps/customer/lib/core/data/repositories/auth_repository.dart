import '../models.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String name, String email, String password);
  Future<void> signOut();
}

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (password == '123456' || email.contains('@')) {
      _currentUser = AppUser(
        id: 'user_123',
        email: email,
        name: 'Demo User',
        photoUrl: 'https://i.pravatar.cc/300',
        phone: '+33 6 12 34 56 78',
      );
      return _currentUser!;
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<AppUser> signUpWithEmail(
      String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    _currentUser = AppUser(
      id: 'user_new_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      photoUrl: 'https://i.pravatar.cc/300',
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }
}
