import 'package:dio/dio.dart';

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
        return const ApiException(
          'Cannot reach DaktariNow right now. Check your connection and try again.',
        );
      }
      return ApiException('Something went wrong (${status ?? 'network'})',
          statusCode: status);
    }
    return ApiException(error.toString());
  }

  final String message;
  final int? statusCode;

  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}
