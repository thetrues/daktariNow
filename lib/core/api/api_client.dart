import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import 'config.dart';

/// Authenticated client. On a 401 it refreshes the access token once and
/// retries; if refresh fails the session ends and the router shows sign-in.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));

  dio.interceptors.add(QueuedInterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(authControllerProvider).accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
    onError: (error, handler) async {
      final req = error.requestOptions;
      if (error.response?.statusCode != 401 || req.extra['retried'] == true) {
        return handler.next(error);
      }
      final current = ref.read(authControllerProvider).accessToken;
      // A queued request may have been sent before another one refreshed.
      final token = current != null &&
              req.headers['Authorization'] != 'Bearer $current'
          ? current
          : await ref.read(authControllerProvider.notifier).refresh();
      if (token == null) return handler.next(error);

      req.headers['Authorization'] = 'Bearer $token';
      req.extra['retried'] = true;
      try {
        handler.resolve(await dio.fetch<dynamic>(req));
      } on DioException catch (e) {
        handler.next(e);
      }
    },
  ));
  return dio;
});
