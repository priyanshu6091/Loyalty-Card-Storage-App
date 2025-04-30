import 'dart:async';

// Mock user class to replace Firebase User
class MockUser {
  final String uid;
  final String email;
  final String displayName;

  MockUser({
    required this.uid,
    required this.email,
    this.displayName = '',
  });
}

// Mock authentication service that doesn't rely on Firebase
class MockAuthService {
  MockUser? _currentUser;
  final StreamController<MockUser?> _authStateController = StreamController<MockUser?>.broadcast();

  // Get current user
  MockUser? get currentUser => _currentUser;

  // Stream of auth state changes
  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Sign in with email and password
  Future<MockUser?> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock authentication logic
    if (email.contains('@') && password.length >= 6) {
      _currentUser = MockUser(
        uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      
      _authStateController.add(_currentUser);
      return _currentUser;
    } else {
      // Simulate auth failed
      throw Exception('Invalid email or password');
    }
  }

  // Register with email and password
  Future<MockUser?> registerWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Mock registration logic
    if (email.contains('@') && password.length >= 6) {
      _currentUser = MockUser(
        uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      
      _authStateController.add(_currentUser);
      return _currentUser;
    } else {
      // Simulate registration failed
      throw Exception('Invalid email or password format');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _authStateController.add(null);
  }

  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
} 