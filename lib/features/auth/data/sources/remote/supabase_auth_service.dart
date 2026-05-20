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

    const String desktopRedirectUrl = 'io.supabase.orbit://login-callback';

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // للديسكتوب: نستخدم الرابط المباشر عشان المتصفح ميفضلش يحمل
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: desktopRedirectUrl,
        queryParams: {'prompt': 'select_account'},
      );
      return null;
    }

    // للموبايل (Native)
    const webClientId = '957809884584-r3e96g4d84hveuhkn5g41sadik49me4g.apps.googleusercontent.com';
    const iosClientId = '957809884584-u7u6dq6chcibikna1tm83dr0d14g26dn.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final accessToken = googleAuth?.accessToken;
      final idToken = googleAuth?.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Google Sign-In failed: Missing tokens';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<String?> uploadAvatar(Uint8List bytes, String name) async {
    try {
      final extension = name.split('.').last;
      final userId = _supabase.auth.currentUser?.id ?? 'anonymous';
      
      // وضع الصورة داخل مجلد باسم الـ User ID لضمان عدم التصادم نهائياً
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _supabase.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );

      return _supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> deleteAvatar(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      if (!url.contains('supabase.co')) return;
      final String cleanUrl = url.split('?').first;
      
      final RegExp regExp = RegExp(r'\/avatars\/(.+)');
      final match = regExp.firstMatch(cleanUrl);

      if (match != null && match.groupCount >= 1) {
        final fileName = Uri.decodeComponent(match.group(1)!);
        
        // التأكد من المسح الفعلي زي مشروعك القديم
        final List<FileObject> response = await _supabase.storage.from('avatars').remove([fileName]);
        
        if (response.isNotEmpty) {
          debugPrint("✅ Successfully deleted old avatar: $fileName");
        } else {
          debugPrint("⚠️ File not found in storage or deletion failed (Check Policies!): $fileName");
        }
      }
    } catch (e) {
      debugPrint("❌ Error during storage deletion: $e");
    }
  }

  Future<void> updateUserMetadata({required String name, String? avatarUrl}) async {
    await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': name,
          'avatar_url': avatarUrl, // بنبعت القيمة حتى لو نل عشان تمسح القديم
        },
      ),
    );
  }
}
