import 'package:uuid/uuid.dart';
import 'api_service.dart';
import 'crypto_service.dart';
import '../models/record_model.dart';

class SyncService {
  final ApiService _api;
  final CryptoService _crypto;
  final _uuid = const Uuid();

  SyncService(this._api, this._crypto);

  Future<void> pushItem(String content) async {
    final entityId = _uuid.v4();
    final encrypted = _crypto.encrypt(content);

    // Wrap in list as backend expects bulk push
    // Note: 'auth_tag' is required by backend DTO but not used by AES-CBC.
    // We send dummy tag or empty.
    final payload = [{
      'entity_id': entityId,
      'collection_name': 'default',
      'ciphertext': encrypted.ciphertext,
      'iv': encrypted.iv,
      'auth_tag': 'none', 
      'version': 1,
    }];

    // ApiService handles JSON encoding
    await _api.post('/sync/push', payload); 
  }

  Future<List<VaultRecord>> pullItems() async {
    // We pull all for now (no timestamp)
    final response = await _api.get('/sync/pull');
    
    // Response is List<dynamic>
    final List<dynamic> data = response as List<dynamic>;
    
    return data.map((item) {
      try {
        final decrypted = _crypto.decrypt(item['ciphertext'], item['iv']);
        return VaultRecord(
          entityId: item['entity_id'],
          content: decrypted,
          updatedAt: DateTime.parse(item['updated_at']),
        );
      } catch (e) {
        // Return a placeholder for decryption errors
        return VaultRecord(
          entityId: item['entity_id'], 
          content: 'Error: Could not decrypt', 
          updatedAt: DateTime.parse(item['updated_at'])
        );
      }
    }).toList();
  }
}
