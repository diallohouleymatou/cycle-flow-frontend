import 'package:encrypt/encrypt.dart';

class CryptoService {
  late Key _key;

  void setKeyFromHex(String hexKey) {
    // Ensure we have a valid key length. 
    // SHA256 output is 64 hex chars (32 bytes), which fits AES-256 perfectly.
    // If shorter/longer, adjust.
    if (hexKey.length < 64) {
      // Pad or error? For now, assume correct input from SRP.
      throw Exception('Key too short');
    }
    if (hexKey.length > 64) {
      hexKey = hexKey.substring(0, 64);
    }
    _key = Key.fromBase16(hexKey);
  }

  EncryptedData encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return EncryptedData(encrypted.base64, iv.base64);
  }

  String decrypt(String ciphertext, String ivBase64) {
    final iv = IV.fromBase64(ivBase64);
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    return encrypter.decrypt64(ciphertext, iv: iv);
  }
}

class EncryptedData {
  final String ciphertext;
  final String iv;
  EncryptedData(this.ciphertext, this.iv);
}
