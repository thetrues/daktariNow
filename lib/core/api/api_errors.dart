import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Strings for code without a BuildContext; follows the app language.
AppLocalizations get currentL10n {
  final code = Intl.shortLocale(Intl.defaultLocale ?? 'en');
  return lookupAppLocalizations(
    Locale(AppLocalizations.delegate.isSupported(Locale(code)) ? code : 'en'),
  );
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Turns any error into a message fit to show the user, preferring the
  /// API's own message.
  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final data = error.response?.data;
      final status = error.response?.statusCode;
      if (data is Map && data['message'] != null) {
        final m = data['message'];
        return ApiException(
          m is List ? m.join('\n') : m.toString(),
          statusCode: status,
        );
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return ApiException(currentL10n.errorOffline);
      }
      return ApiException(
        currentL10n.errorGeneric('${status ?? 'network'}'),
        statusCode: status,
      );
    }
    return ApiException(error.toString());
  }

  final String message;
  final int? statusCode;

  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}
