import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Mock storage service that uses shared preferences instead of Firebase
class MockStorageService {
  late SharedPreferences _prefs;
  final String _cardsKey = 'loyalty_cards';
  
  // Initialize the storage service
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('Error initializing shared preferences: $e');
    }
  }

  // Get all loyalty cards
  Future<List<Map<String, dynamic>>> getCards() async {
    try {
      final String? cardsJson = _prefs.getString(_cardsKey);
      if (cardsJson == null) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(cardsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error getting cards: $e');
      return [];
    }
  }

  // Save a new loyalty card
  Future<bool> saveCard(Map<String, dynamic> card) async {
    try {
      final cards = await getCards();
      
      // Generate a unique ID if not provided
      if (!card.containsKey('id')) {
        card['id'] = 'card_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Add creation timestamp
      card['createdAt'] = DateTime.now().toIso8601String();
      
      cards.add(card);
      return await _saveCards(cards);
    } catch (e) {
      print('Error saving card: $e');
      return false;
    }
  }

  // Update an existing loyalty card
  Future<bool> updateCard(String id, Map<String, dynamic> updates) async {
    try {
      final cards = await getCards();
      final index = cards.indexWhere((card) => card['id'] == id);
      
      if (index >= 0) {
        updates['updatedAt'] = DateTime.now().toIso8601String();
        cards[index] = {...cards[index], ...updates};
        return await _saveCards(cards);
      }
      return false;
    } catch (e) {
      print('Error updating card: $e');
      return false;
    }
  }

  // Delete a loyalty card
  Future<bool> deleteCard(String id) async {
    try {
      final cards = await getCards();
      final filteredCards = cards.where((card) => card['id'] != id).toList();
      
      if (filteredCards.length < cards.length) {
        return await _saveCards(filteredCards);
      }
      return false;
    } catch (e) {
      print('Error deleting card: $e');
      return false;
    }
  }

  // Save the entire card list to storage
  Future<bool> _saveCards(List<Map<String, dynamic>> cards) async {
    try {
      final String encoded = jsonEncode(cards);
      return await _prefs.setString(_cardsKey, encoded);
    } catch (e) {
      print('Error saving cards: $e');
      return false;
    }
  }

  // Clear all stored data
  Future<bool> clearStorage() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      print('Error clearing storage: $e');
      return false;
    }
  }
} 