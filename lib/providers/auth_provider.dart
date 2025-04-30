import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loyalty_wallet/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  
  AuthProvider(this._authService) {
    _init();
  }
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  Future<void> _init() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } on FirebaseAuthException catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.registerWithEmailAndPassword(email, password);
      return true;
    } on FirebaseAuthException catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
