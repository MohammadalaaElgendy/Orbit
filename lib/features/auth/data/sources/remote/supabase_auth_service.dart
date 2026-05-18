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
  }) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      data: {
        'full_name': name,
        'avatar_url': avatarUrl,
      }..removeWhere((key, value) => value == null),
      shouldCreateUser: true,
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
    const String redirectUrl = 'io.supabase.orbit://login-callback';

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For Desktop and Web, we use OAuth with redirect
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        queryParams: {'prompt': 'select_account'},
      );
      return null;
    } else {
      // For Mobile (Native)
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
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    final extension = fileName.split('.').last;
    final path = 'public/${DateTime.now().millisecondsSinceEpoch}.$extension';
    
    await _supabase.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$extension', upsert: true),
    );

    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> updateUserMetadata({required String name, String? avatarUrl}) async {
    await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': name,
          'avatar_url': avatarUrl,
        }..removeWhere((key, value) => value == null),
      ),
    );
  }
}
