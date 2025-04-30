import 'dart:async';
import 'dart:math';
import 'package:loyalty_wallet/services/mock_storage_service.dart';
import 'package:loyalty_wallet/services/mock_auth_service.dart';

class MockSyncService {
  final MockStorageService _storageService;
  final MockAuthService _authService;
  
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;
  
  MockSyncService(this._storageService, this._authService) {
    // Start periodic background sync
    _setupPeriodicSync();
  }
  
  // Get sync status
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  // Setup periodic sync
  void _setupPeriodicSync() {
    // Run sync every 15 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (_authService.currentUser != null) {
        syncData();
      }
    });
  }
  
  // Sync data with mock "cloud"
  Future<bool> syncData() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    bool success = false;
    
    try {
      // Only sync if user is authenticated
      if (_authService.currentUser == null) {
        _isSyncing = false;
        return false;
      }
      
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)));
      
      // Get local data
      final localCards = await _storageService.getCards();
      
      // Mock successful sync
      success = true;
      _lastSyncTime = DateTime.now();
      print('Data synced successfully at $_lastSyncTime (${localCards.length} cards)');
    } catch (e) {
      print('Error syncing data: $e');
      success = false;
    } finally {
      _isSyncing = false;
    }
    
    return success;
  }
  
  // Force immediate sync
  Future<bool> forceSyncData() async {
    return syncData();
  }
  
  // Clean up resources
  void dispose() {
    _syncTimer?.cancel();
  }
} 