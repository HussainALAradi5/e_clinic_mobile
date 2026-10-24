import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The Sanctum token in the Keychain / Android Keystore, with an in-memory copy for the auth interceptor.
/// Never written to shared preferences or logs.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'ec.token';

  String? _current;
  bool _loaded = false;

  /// Token sent with requests (null when signed out or not loaded yet).
  String? get current => _current;

  Future<String?> read() async {
    if (!_loaded) {
      _current = await _storage.read(key: _key);
      _loaded = true;
    }
    return _current;
  }

  Future<void> write(String token) async {
    _current = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  Future<void> clear() async {
    _current = null;
    _loaded = true;
    await _storage.delete(key: _key);
  }
}
