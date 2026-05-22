import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import '../../../../shared/models/user.dart' as model;
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;
  static const _channel = MethodChannel('com.orbit.app/deep_link');

  model.User? user;
  bool isLoading = false;
  String? errorMessage;
  bool? userExists;
  
  final _loginSuccessController = StreamController<bool>.broadcast();
  Stream<bool> get loginSuccessStream => _loginSuccessController.stream;

  Uint8List? pickedAvatarBytes;
  String? pickedAvatarName;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final _supabase = Supabase.instance.client;

  AuthViewModel({required this.authRepository}) {
    _init();
    _setupDeepLinks();
    _setupNativeChannel();
  }

  void _setupNativeChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onLinkReceived") {
        final String? url = call.arguments;
        if (url != null) {
          _handleIncomingUri(Uri.parse(url));
        }
      }
    });
  }

  void _init() {
    user = authRepository.currentUser;
    // الاستماع لأي تغيير في حالة تسجيل الدخول
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        user = authRepository.currentUser;
        isLoading = false;
        _loginSuccessController.add(true);
        notifyListeners();
      }
    });
  }

  void _setupDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (e) { }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(uri);
    });
  }

  void _handleIncomingUri(Uri uri) async {
    String urlStr = uri.toString();

    if (urlStr.contains('#')) {
      urlStr = urlStr.replaceFirst('#', '?');
    }

    try {
      await _supabase.auth.getSessionFromUrl(Uri.parse(urlStr));
      user = authRepository.currentUser;
      isLoading = false;
      _loginSuccessController.add(true);
      notifyListeners();
        } catch (e) {
      if (e.toString().contains('session already established')) {
        isLoading = false;
        _loginSuccessController.add(true);
        notifyListeners();
      } else {
        isLoading = false;
        errorMessage = _cleanErrorMessage(e.toString());
        notifyListeners();
      }
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await authRepository.signInWithGoogle();
      
      user = authRepository.currentUser;
      if (user != null) {
        isLoading = false;
        _loginSuccessController.add(true);
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = _cleanErrorMessage(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> checkUserExistence() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      errorMessage = "Please enter a valid email address.";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
      userExists = true;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('user not found') || msg.contains('signups not allowed') || msg.contains('otp_disabled')) {
        userExists = false;
      } else {
        errorMessage = e.message;
      }
    } catch (e) {
      errorMessage = _cleanErrorMessage(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _cleanErrorMessage(String rawError) {
    if (rawError.contains('AuthApiException') || rawError.contains('AuthException')) {
      final regex = RegExp(r'message: (.*?),');
      final match = regex.firstMatch(rawError);
      return match?.group(1) ?? rawError.split(':').last.trim();
    }
    if (rawError.contains('StorageException')) {
      if (rawError.contains('Bucket not found')) return "Storage bucket 'avatars' is missing.";
      if (rawError.contains('403')) return "Storage Permission Denied (RLS).";
      return "Error uploading image.";
    }
    return rawError;
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    if (email.isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      String? avatarUrl;
      if (pickedAvatarBytes != null && pickedAvatarName != null) {
        final compressedBytes = await compute(_compressImage, pickedAvatarBytes!);
        avatarUrl = await authRepository.uploadAvatar(compressedBytes, pickedAvatarName!);
      }
      await _supabase.auth.signInWithOtp(
        email: email,
        data: {
          'full_name': name,
          'avatar_url': avatarUrl,
        },
        shouldCreateUser: true,
      );
    } catch (e) {
      errorMessage = _cleanErrorMessage(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp() async {
    final email = emailController.text.trim();
    final token = otpController.text.trim();
    if (email.isEmpty || token.isEmpty) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: userExists == false ? OtpType.signup : OtpType.email,
      );
      return true;
    } catch (e) {
      errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  static Uint8List _compressImage(Uint8List bytes) {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;
    if (image.width > 400) image = img.copyResize(image, width: 400);
    return Uint8List.fromList(img.encodeJpg(image, quality: 70));
  }

  Future<void> pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.single.bytes != null) {
        pickedAvatarBytes = result.files.single.bytes!;
        pickedAvatarName = result.files.single.name;
        notifyListeners();
      }
    } catch (e) { }
  }

  Future<void> updateProfileAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.single.bytes != null) {
        isLoading = true;
        notifyListeners();
        final compressedBytes = await compute(_compressImage, result.files.single.bytes!);
        await authRepository.updateAvatar(compressedBytes, result.files.single.name);
        user = authRepository.currentUser;
      }
    } catch (e) { errorMessage = _cleanErrorMessage(e.toString()); } 
    finally { isLoading = false; notifyListeners(); }
  }

  Future<void> deleteProfileAvatar() async {
    try {
      isLoading = true;
      notifyListeners();
      await authRepository.deleteAvatar();
      user = authRepository.currentUser;
    } catch (e) { errorMessage = _cleanErrorMessage(e.toString()); } 
    finally { isLoading = false; notifyListeners(); }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    user = null;
    emailController.clear();
    nameController.clear();
    otpController.clear();
    userExists = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    emailController.dispose();
    nameController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
