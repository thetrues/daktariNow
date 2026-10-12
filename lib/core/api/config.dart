import 'package:flutter/foundation.dart';

/// API base URL. Override for staging/production:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1`
///
/// Defaults to the local backend. The Android emulator reaches the host
/// machine at 10.0.2.2, not localhost.
String get apiBaseUrl {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;
  final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';
  return 'http://$host:3000/api/v1';
}
