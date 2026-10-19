import 'package:flutter/foundation.dart';

/// The production API, used by release builds unless overridden.
const productionApiBaseUrl = 'https://api.daktarinow.com/api/v1';

/// API base URL. Override for staging or a LAN test server:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1`
///
/// Without an override, release builds use [productionApiBaseUrl] and debug
/// builds use the local backend (the Android emulator reaches the host
/// machine at 10.0.2.2, not localhost).
String get apiBaseUrl {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;
  if (kReleaseMode) return productionApiBaseUrl;
  final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';
  return 'http://$host:3000/api/v1';
}
