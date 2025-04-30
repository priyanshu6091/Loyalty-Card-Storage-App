import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:loyalty_wallet/services/storage_service.dart';
import 'package:loyalty_wallet/services/sync_service.dart';
import 'package:loyalty_wallet/services/notification_service.dart';

class CardProvider with ChangeNotifier {
  final StorageService _storageService;
  final SyncService _syncService;
  final NotificationService _notificationService;
  
  List<LoyaltyCard> _cards = [];
  bool _isLoading = false;
  
  CardProvider(this._storageService, this._syncService, this._notificationService) {
    _loadCards();
  }
  
  List<LoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;
  
  Future<void> _loadCards() async {
    _isLoading = true;
    notifyListeners();
    
    _cards = await _storageService.getAllCards();
    
    _isLoading = false;
    notifyListeners();
    
    // Trigger sync after loading cards
    _syncService.triggerSync();
  }
  
  Future<void> addCard(LoyaltyCard card) async {
    await _storageService.saveCard(card);
    
    // Schedule notification if card has expiry date
    if (card.expiryDate != null) {
      await _notificationService.scheduleExpirationNotification(card);
    }
    
    _cards = await _storageService.getAllCards();
    notifyListeners();
    
    _syncService.triggerSync();
  }
  
  Future<void> updateCard(LoyaltyCard updatedCard) async {
    await _storageService.saveCard(updatedCard);
    
    // Update expiration notification
    await _notificationService.cancelNotification(updatedCard);
    if (updatedCard.expiryDate != null) {
      await _notificationService.scheduleExpirationNotification(updatedCard);
    }
    
    _cards = await _storageService.getAllCards();
    notifyListeners();
    
    _syncService.triggerSync();
  }
  
  Future<void> deleteCard(String id) async {
    final card = await _storageService.getCard(id);
    if (card != null) {
      await _notificationService.cancelNotification(card);
      await _storageService.deleteCard(id);
      
      _cards = await _storageService.getAllCards();
      notifyListeners();
      
      _syncService.triggerSync();
    }
  }
  
  Future<LoyaltyCard?> getCard(String id) async {
    return await _storageService.getCard(id);
  }
  
  Future<void> refreshCards() async {
    await _loadCards();
  }
  
  Future<String> saveCardImage(File imageFile, String cardId) async {
    return await _storageService.saveCardImage(imageFile, cardId);
  }
  
  List<LoyaltyCard> getExpiringSoonCards(int days) {
    return _cards.where((card) => card.isExpiringSoon(days)).toList();
  }
  
  List<LoyaltyCard> getExpiredCards() {
    return _cards.where((card) => card.isExpired()).toList();
  }
  
  List<LoyaltyCard> searchCards(String query) {
    if (query.isEmpty) return _cards;
    
    final lowerCaseQuery = query.toLowerCase();
    return _cards.where((card) =>
      card.name.toLowerCase().contains(lowerCaseQuery) ||
      card.cardNumber.toLowerCase().contains(lowerCaseQuery) ||
      (card.notes?.toLowerCase().contains(lowerCaseQuery) ?? false)
    ).toList();
  }
}
