import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  late Key _key;
  late IV _iv;
  late Encrypter _encrypter;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _keyName = 'encryption_key';
  static const String _ivName = 'encryption_iv';

  EncryptionHelper() {
    _initEncryption();
  }
  
  Future<void> _initEncryption() async {
    // Try to get existing key and IV
    String? storedKey = await _secureStorage.read(key: _keyName);
    String? storedIV = await _secureStorage.read(key: _ivName);
    
    if (storedKey == null || storedIV == null) {
      // Generate new key and IV if not exist
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(16);
      
      // Store them securely
      await _secureStorage.write(key: _keyName, value: base64Encode(key.bytes));
      await _secureStorage.write(key: _ivName, value: base64Encode(iv.bytes));
      
      _key = key;
      _iv = iv;
    } else {
      // Use existing key and IV
      _key = Key(base64Decode(storedKey));
      _iv = IV(base64Decode(storedIV));
    }
    
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  String encrypt(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedData) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // In case the data wasn't encrypted
      return encryptedData;
    }
  }
}
