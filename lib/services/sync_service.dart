import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:loyalty_wallet/services/auth_service.dart';
import 'package:loyalty_wallet/services/storage_service.dart';

class SyncService {
  final StorageService _storageService;
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(this._storageService, this._authService) {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      await syncData();
    }
  }

  Future<void> syncData() async {
    if (_isSyncing || !_authService.isAuthenticated()) return;

    _isSyncing = true;
    
    try {
      // Get local changes
      final unsyncedCards = await _storageService.getUnsyncedCards();
      
      if (unsyncedCards.isEmpty) {
        await _pullChangesFromCloud();
        _isSyncing = false;
        return;
      }
      
      // Push local changes to cloud
      for (final card in unsyncedCards) {
        if (card.isDeleted) {
          await _firestore
              .collection('users')
              .doc(_authService.currentUser!.uid)
              .collection('cards')
              .doc(card.id)
              .delete();
              
          await _storageService.hardDeleteCard(card.id);
        } else {
          await _firestore
              .collection('users')
              .doc(_authService.currentUser!.uid)
              .collection('cards')
              .doc(card.id)
              .set(card.toJson());
              
          await _storageService.markAsSynced(card.id);
        }
      }
      
      // Pull changes from cloud
      await _pullChangesFromCloud();
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pullChangesFromCloud() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_authService.currentUser!.uid)
        .collection('cards')
        .get();
    
    for (final doc in snapshot.docs) {
      final cloudCard = LoyaltyCard.fromJson(doc.data());
      final localCard = await _storageService.getCard(cloudCard.id);
      
      // If card doesn't exist locally or cloud is newer
      if (localCard == null || 
          cloudCard.updatedAt.isAfter(localCard.updatedAt)) {
        await _storageService.saveCard(cloudCard.copyWith(isSynced: true));
      }
    }
  }

  // Start immediate sync
  Future<void> triggerSync() async {
    return syncData();
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
