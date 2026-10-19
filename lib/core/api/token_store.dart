import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the refresh token lives between app launches.
abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

/// Keychain on iOS, encrypted storage on Android, WebCrypto-encrypted
/// storage on the web.
///
/// Browsers only offer WebCrypto on https or localhost. When secure storage
/// is unavailable (e.g. the web app opened over plain http on a LAN address
/// during development) the token is kept in memory instead: sign-in works,
/// but the session ends when the page reloads.
class SecureTokenStore implements TokenStore {
  static const _key = 'medic_refresh_token';
  final _storage = const FlutterSecureStorage();
  String? _memory;
  bool _unavailable = false;

  @override
  Future<String?> read() async {
    if (_unavailable) return _memory;
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      _unavailable = true;
      return _memory;
    }
  }

  @override
  Future<void> write(String token) async {
    _memory = token;
    if (_unavailable) return;
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {
      _unavailable = true;
    }
  }

  @override
  Future<void> clear() async {
    _memory = null;
    if (_unavailable) return;
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      _unavailable = true;
    }
  }
}

/// For tests.
class MemoryTokenStore implements TokenStore {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String token) async => _value = token;

  @override
  Future<void> clear() async => _value = null;
}

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
