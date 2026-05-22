import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> signInWithOtp({
    required String email,
    String? name,
    String? avatarUrl,
    bool shouldCreateUser = true,
  }) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      data: {
        'full_name': name,
        'avatar_url': avatarUrl,
      }..removeWhere((key, value) => value == null),
      shouldCreateUser: shouldCreateUser,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<AuthResponse?> signInWithGoogle() async {
    if (kIsWeb) throw 'Google Sign-In not implemented for Web yet.';

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // للديسكتوب: نستخدم الطريقة التي نجحت معك سابقاً
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.orbit://login-callback',
        queryParams: {'prompt': 'select_account'},
      );
      return null;
    }

    // للموبايل (الأندرويد والآيفون)
    const webClientId = '957809884584-96v9q0kmds218or9p8qclovvj1ssneea.apps.googleusercontent.com';
    const iosClientId = '957809884584-u7u6dq6chcibikna1tm83dr0d14g26dn.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? iosClientId : null,
      serverClientId: webClientId,
    );
    
    // إجبار ظهور قائمة اختيار الحسابات عن طريق تسجيل الخروج من جوجل أولاً
    try {
      await googleSignIn.signOut();
    } catch (_) {}
    
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;

    if (googleAuth?.accessToken == null || googleAuth?.idToken == null) return null;

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth!.idToken!,
      accessToken: googleAuth.accessToken!,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<String?> uploadAvatar(Uint8List bytes, String name) async {
    try {
      final extension = name.split('.').last;
      final userId = _supabase.auth.currentUser?.id ?? 'anonymous';
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
      await _supabase.storage.from('avatars').uploadBinary(
        fileName, bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      return _supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) { return null; }
  }

  Future<void> deleteAvatar(String? url) async {
    if (url == null || !url.contains('supabase.co')) return;
    try {
      final String cleanUrl = url.split('?').first;
      final RegExp regExp = RegExp(r'\/avatars\/(.+)');
      final match = regExp.firstMatch(cleanUrl);
      if (match != null) {
        final fileName = Uri.decodeComponent(match.group(1)!);
        await _supabase.storage.from('avatars').remove([fileName]);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting avatar: $e');
      }
    }
  }

  Future<void> updateUserMetadata({required String name, String? avatarUrl}) async {
    await _supabase.auth.updateUser(UserAttributes(data: {'full_name': name, 'avatar_url': avatarUrl}));
  }
}
