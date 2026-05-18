import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../shared/models/user.dart';
import '../../data/sources/remote/supabase_auth_service.dart';
import 'user_repository.dart';

class AuthRepository {
  final SupabaseAuthService _authService;
  final UserRepository _userRepository;

  AuthRepository(this._authService, this._userRepository) {
    // Listen to auth changes and sync with local DB automatically
    _authService.authStateChanges.listen((data) async {
      final sUser = data.session?.user;
      if (sUser != null) {
        final user = User(
          id: sUser.id,
          name: sUser.userMetadata?['full_name'] ?? sUser.email?.split('@').first ?? 'User',
          email: sUser.email ?? '',
          avatarUrl: sUser.userMetadata?['avatar_url'],
          isVerified: sUser.emailConfirmedAt != null,
          authProvider: sUser.appMetadata['provider'] ?? 'email',
        );
        
        final existingUser = await _userRepository.getUserById(user.id);
        if (existingUser == null) {
          await _userRepository.createUser(user);
        }
      }
    });
  }

  Stream<supabase.AuthState> get authStateChanges => _authService.authStateChanges;

  User? get currentUser {
    final sUser = _authService.currentUser;
    if (sUser == null) return null;
    
    return User(
      id: sUser.id,
      name: sUser.userMetadata?['full_name'] ?? '',
      email: sUser.email ?? '',
      avatarUrl: sUser.userMetadata?['avatar_url'],
      isVerified: sUser.emailConfirmedAt != null,
    );
  }

  Future<void> signInWithOtp(String email, {String? name, String? avatarUrl}) async {
    await _authService.signInWithOtp(email: email, name: name, avatarUrl: avatarUrl);
  }

  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    return await _authService.uploadAvatar(bytes, fileName);
  }

  Future<void> verifyOtp(String email, String token) async {
    final response = await _authService.verifyOtp(email: email, token: token);
    final sUser = response.user;
    
    if (sUser != null) {
      final user = User(
        id: sUser.id,
        name: sUser.userMetadata?['full_name'] ?? '',
        email: sUser.email ?? '',
        avatarUrl: sUser.userMetadata?['avatar_url'],
        isVerified: true,
        authProvider: 'email',
      );
      
      // Sync with local database
      final existingUser = await _userRepository.getUserById(user.id);
      if (existingUser == null) {
        await _userRepository.createUser(user);
      } else {
        // Update local user if needed
      }
    }
  }

  Future<void> signInWithGoogle() async {
    final response = await _authService.signInWithGoogle();
    if (response?.user != null) {
      final sUser = response!.user!;
      final user = User(
        id: sUser.id,
        name: sUser.userMetadata?['full_name'] ?? '',
        email: sUser.email ?? '',
        avatarUrl: sUser.userMetadata?['avatar_url'],
        isVerified: true,
        authProvider: 'google',
      );
      
      final existingUser = await _userRepository.getUserById(user.id);
      if (existingUser == null) {
        await _userRepository.createUser(user);
      }
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
