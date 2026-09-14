import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores sensitive keys in platform secure storage (Keychain / Keystore).
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _groqKey = 'northstar_groq_api_key';

  String? _cachedGroqKey;

  Future<String?> getGroqApiKey() async {
    _cachedGroqKey ??= await _storage.read(key: _groqKey);
    return _cachedGroqKey;
  }

  Future<bool> hasGroqKey() async {
    final key = await getGroqApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<void> setGroqApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _storage.delete(key: _groqKey);
      _cachedGroqKey = null;
    } else {
      await _storage.write(key: _groqKey, value: key.trim());
      _cachedGroqKey = key.trim();
    }
  }

  Future<void> clearGroqKey() => setGroqApiKey(null);
}
