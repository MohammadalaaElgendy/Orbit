import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BaseViewModel extends ChangeNotifier {
  final List<StreamSubscription> _subscriptions = [];
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BaseViewModel() {
    _listenToAuth();
  }

  void _listenToAuth() {
    addSubscription(
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.session == null) {
          onLoggedOut();
        }
      })
    );
  }

  /// Override this to clear specific data on logout
  @mustCallSuper
  void onLoggedOut() {
    clearSubscriptions();
    notifyListeners();
  }

  void addSubscription(StreamSubscription sub) {
    _subscriptions.add(sub);
  }

  void clearSubscriptions() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clearSubscriptions();
    super.dispose();
  }
}
