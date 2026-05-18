import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  User? user;
  bool isLoading = false;
  String? errorMessage;
  bool? userExists;
  
  // Stream to notify UI about successful login for navigation
  final _loginSuccessController = StreamController<bool>.broadcast();
  Stream<bool> get loginSuccessStream => _loginSuccessController.stream;

  Uint8List? pickedAvatarBytes;
  String? pickedAvatarName;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  AuthViewModel({required this.authRepository}) {
    _init();
  }

  void _init() {
    user = authRepository.currentUser;
    authRepository.authStateChanges.listen((data) {
      user = authRepository.currentUser;
      if (user != null && user!.isVerified) {
        _loginSuccessController.add(true);
      }
      notifyListeners();
    });
  }

  Future<void> pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        pickedAvatarBytes = result.files.single.bytes!;
        pickedAvatarName = result.files.single.name;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking avatar: $e");
    }
  }

  Future<void> checkUserExistence() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await authRepository.signInWithOtp(email, shouldCreateUser: false);
      userExists = true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('user not found') || msg.contains('signups not allowed') || msg.contains('not allowed')) {
        userExists = false;
      } else {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
        avatarUrl = await authRepository.uploadAvatar(pickedAvatarBytes!, pickedAvatarName!);
      }
      
      await authRepository.signInWithOtp(
        email, 
        name: name.isNotEmpty ? name : null,
        avatarUrl: avatarUrl,
        shouldCreateUser: true,
      );
    } catch (e) {
      errorMessage = e.toString();
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
      await authRepository.verifyOtp(email, token);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await authRepository.signInWithGoogle();
      // Ensure we navigate directly on success if stream misses it
      _loginSuccessController.add(true);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
    user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
