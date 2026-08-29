import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../shared/models/user.dart';
import '../../data/sources/remote/supabase_auth_service.dart';
import 'user_repository.dart';

class AuthRepository {
  final SupabaseAuthService _authService;
  final UserRepository _userRepository;

  AuthRepository(this._authService, this._userRepository) {
    // الاستماع التلقائي لتغييرات الحالة وحفظ البيانات فوراً
    _authService.authStateChanges.listen((data) async {
      final sUser = data.session?.user ?? _authService.currentUser;
      if (sUser != null) {
        final user = _mapSupabaseUserToModel(sUser);
        try {
          await _userRepository.createUser(user);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error syncing user to local DB: $e');
          }
        }
      }
    });
  }

  Future<void> syncCurrentUser() async {
    final user = currentUser;
    if (user != null) {
      await _userRepository.createUser(user);
    }
  }

  // وظيفة موحدة لتحويل مستخدم سوبابيس إلى الموديل الخاص بنا
  User _mapSupabaseUserToModel(supabase.User sUser) {
    final metadata = sUser.userMetadata ?? {};
    
    // البحث عن الاسم في عدة مفاتيح محتملة
    final String userName = metadata['full_name']?.toString() ?? 
                           metadata['name']?.toString() ?? 
                           sUser.email?.split('@').first ?? 'User';
                           
    // البحث عن الصورة في عدة مفاتيح محتملة (جوجل يستخدم picture أحياناً)
    final String? avatarUrl = metadata['avatar_url']?.toString() ?? 
                             metadata['picture']?.toString();

    return User(
      id: sUser.id,
      name: userName,
      email: sUser.email ?? '',
      avatarUrl: avatarUrl,
      isVerified: sUser.emailConfirmedAt != null || sUser.appMetadata['provider'] == 'google',
      authProvider: sUser.appMetadata['provider']?.toString() ?? 'email',
    );
  }

  Stream<supabase.AuthState> get authStateChanges => _authService.authStateChanges;

  User? get currentUser {
    final sUser = _authService.currentUser;
    if (sUser == null) return null;
    return _mapSupabaseUserToModel(sUser);
  }

  Future<void> signInWithOtp(String email, {String? name, String? avatarUrl, bool shouldCreateUser = true}) async {
    await _authService.signInWithOtp(email: email, name: name, avatarUrl: avatarUrl, shouldCreateUser: shouldCreateUser);
  }

  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    return await _authService.uploadAvatar(bytes, fileName);
  }

  Future<void> verifyOtp(String email, String token) async {
    final response = await _authService.verifyOtp(email: email, token: token);
    final sUser = response.user;
    
    if (sUser != null) {
      final user = _mapSupabaseUserToModel(sUser);
      // حفظ يدوي فوري للتأكد من تسجيل الصورة
      await _userRepository.createUser(user);
    }
  }

  Future<supabase.AuthResponse?> signInWithGoogle() async {
    final response = await _authService.signInWithGoogle();
    if (response?.user != null) {
      final user = _mapSupabaseUserToModel(response!.user!);
      await _userRepository.createUser(user);
    }
    return response;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updateAvatar(Uint8List bytes, String fileName) async {
    final String? oldUrl = currentUser?.avatarUrl;
    final String? newUrl = await _authService.uploadAvatar(bytes, fileName);
    
    if (newUrl != null) {
      await _authService.updateUserMetadata(
        name: currentUser?.name ?? 'User', 
        avatarUrl: newUrl
      );
      
      // تحديث محلي فوري
      if (currentUser != null) {
        await _userRepository.createUser(currentUser!.copyWith(avatarUrl: newUrl));
      }
      
      if (oldUrl != null && oldUrl != newUrl) {
        await _authService.deleteAvatar(oldUrl);
      }
    }
  }

  Future<void> deleteAvatar() async {
    final oldUrl = currentUser?.avatarUrl;
    
    // 1. تحديث سوبابيس (Metadata) بوضع نل
    await _authService.updateUserMetadata(name: currentUser?.name ?? 'User', avatarUrl: null);
    
    // 2. تحديث محلي فوري لمسح اللينك من الـ DB
    if (currentUser != null) {
      final updatedUser = currentUser!.copyWith(avatarUrl: null);
      await _userRepository.createUser(updatedUser);
    }

    // 3. مسح الملف الفعلي من الـ Storage
    if (oldUrl != null) {
      await _authService.deleteAvatar(oldUrl);
    }
  }
}
