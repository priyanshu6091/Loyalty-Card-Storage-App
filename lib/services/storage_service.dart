import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:loyalty_wallet/utils/encryption_helper.dart';

class StorageService {
  late Box<LoyaltyCard> _cardsBox;
  final EncryptionHelper _encryptionHelper = EncryptionHelper();
  
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LoyaltyCardAdapter());
    }
    
    _cardsBox = await Hive.openBox<LoyaltyCard>('cards');
  }

  Future<List<LoyaltyCard>> getAllCards() async {
    return _cardsBox.values.where((card) => !card.isDeleted).toList();
  }

  Future<void> saveCard(LoyaltyCard card) async {
    // Encrypt sensitive data
    final encryptedCardNumber = _encryptionHelper.encrypt(card.cardNumber);
    final secureCard = card.copyWith(cardNumber: encryptedCardNumber, isSynced: false);
    
    await _cardsBox.put(card.id, secureCard);
  }

  Future<LoyaltyCard?> getCard(String id) async {
    final card = _cardsBox.get(id);
    if (card == null) return null;
    
    // Decrypt sensitive data for use
    final decryptedCardNumber = _encryptionHelper.decrypt(card.cardNumber);
    return card.copyWith(cardNumber: decryptedCardNumber);
  }

  Future<void> deleteCard(String id) async {
    final card = _cardsBox.get(id);
    if (card != null) {
      // Soft delete by marking as deleted
      final updatedCard = card.copyWith(isDeleted: true, isSynced: false);
      await _cardsBox.put(id, updatedCard);
    }
  }

  Future<void> hardDeleteCard(String id) async {
    await _cardsBox.delete(id);
  }

  Future<List<LoyaltyCard>> getUnsyncedCards() async {
    return _cardsBox.values.where((card) => !card.isSynced).toList();
  }

  Future<void> markAsSynced(String id) async {
    final card = _cardsBox.get(id);
    if (card != null) {
      final syncedCard = card.copyWith(isSynced: true);
      await _cardsBox.put(id, syncedCard);
    }
  }

  Future<String> saveCardImage(File imageFile, String cardId) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/card_images';
    
    // Create directory if it doesn't exist
    final imageDir = Directory(path);
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final fileName = '$cardId-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$path/$fileName';
    
    await imageFile.copy(filePath);
    return filePath;
  }
}
