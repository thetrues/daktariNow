import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_errors.dart';
import '../../core/api/config.dart';
import '../../core/api/token_store.dart';
import '../../core/models/app_user.dart';

enum AuthStatus { restoring, signedOut, signedIn }

class AuthState {
  const AuthState._(this.status, {this.user, this.accessToken});

  const AuthState.restoring() : this._(AuthStatus.restoring);
  const AuthState.signedOut() : this._(AuthStatus.signedOut);
  const AuthState.signedIn(AppUser user, String accessToken)
      : this._(AuthStatus.signedIn, user: user, accessToken: accessToken);

  final AuthStatus status;
  final AppUser? user;
  final String? accessToken;
}

/// Owns the session: access token in memory, refresh token in secure
/// storage. The router listens to this to pick the patient or doctor shell.
class AuthController extends Notifier<AuthState> {
  // Auth calls go through a client without the refresh interceptor.
  late final Dio _authDio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
  ));
  Future<String?>? _refreshing;

  /// The most recent signed-in user. Screens still mounted during the frame
  /// between sign-out and the router's redirect read this instead of null.
  AppUser? lastUser;

  TokenStore get _store => ref.read(tokenStoreProvider);

  @override
  AuthState build() {
    Future.microtask(_restore);
    return const AuthState.restoring();
  }

  Future<void> _restore() async {
    if (await _store.read() == null) {
      state = const AuthState.signedOut();
    } else {
      await refresh();
    }
  }

  Future<void> signIn(String email, String password) =>
      _authenticate('/auth/login', {'email': email, 'password': password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? specialtyId,
    String? licenseNumber,
  }) =>
      _authenticate('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role == UserRole.doctor ? 'DOCTOR' : 'PATIENT',
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (role == UserRole.doctor) 'specialtyId': specialtyId,
        if (role == UserRole.doctor) 'licenseNumber': licenseNumber,
      });

  Future<void> _authenticate(String path, Map<String, dynamic> body) async {
    try {
      final res = await _authDio.post<Map<String, dynamic>>(path, data: body);
      await _accept(res.data!);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<String> _accept(Map<String, dynamic> body) async {
    final user = AppUser.fromJson(body['user'] as Map<String, dynamic>);
    if (user.role == UserRole.admin) {
      throw const ApiException('Please use the admin console.');
    }
    await _store.write(body['refreshToken'] as String);
    final access = body['accessToken'] as String;
    lastUser = user;
    state = AuthState.signedIn(user, access);
    return access;
  }

  /// Exchanges the refresh token. Concurrent callers share one request:
  /// refresh tokens rotate, and reusing one makes the API revoke every
  /// session for this user.
  Future<String?> refresh() => _refreshing ??= _doRefresh().whenComplete(() {
        _refreshing = null;
      });

  Future<String?> _doRefresh() async {
    final token = await _store.read();
    if (token == null) {
      state = const AuthState.signedOut();
      return null;
    }
    try {
      final res = await _authDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': token},
      );
      return await _accept(res.data!);
    } on DioException catch (e) {
      // Network failure, not a rejected token: keep the stored token so the
      // session survives. At launch, fall back to the sign-in screen; the
      // next launch will try again.
      if (e.response == null) {
        if (state.status == AuthStatus.restoring) {
          state = const AuthState.signedOut();
        }
        return null;
      }
      await _store.clear();
      state = const AuthState.signedOut();
      return null;
    } catch (_) {
      await _store.clear();
      state = const AuthState.signedOut();
      return null;
    }
  }

  /// Re-reads the profile, e.g. to see whether a doctor was approved.
  Future<void> reloadUser() async {
    final access = state.accessToken;
    if (access == null) return;
    try {
      final res = await _authDio.get<Map<String, dynamic>>(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
      final user = AppUser.fromJson(res.data!);
      lastUser = user;
      state = AuthState.signedIn(user, access);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && await refresh() != null) return;
      throw ApiException.from(e);
    }
  }

  /// Replaces the cached user after a profile edit (the API returns it).
  void updateUser(Map<String, dynamic> json) {
    final access = state.accessToken;
    if (access == null) return;
    final user = AppUser.fromJson(json);
    lastUser = user;
    state = AuthState.signedIn(user, access);
  }

  /// The API signs out every other session and returns fresh tokens for
  /// this one.
  Future<void> changePassword(String current, String next) async {
    final access = state.accessToken;
    if (access == null) throw const ApiException('Please sign in again');
    try {
      final res = await _authDio.post<Map<String, dynamic>>(
        '/auth/change-password',
        data: {'currentPassword': current, 'newPassword': next},
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
      await _accept(res.data!);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> signOut() async {
    final token = await _store.read();
    await _store.clear();
    state = const AuthState.signedOut();
    if (token != null) {
      try {
        await _authDio.post<void>('/auth/logout', data: {'refreshToken': token});
      } catch (_) {
        // Signed out locally either way; the token expires server-side.
      }
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// For screens that are only reachable when signed in.
final currentUserProvider = Provider<AppUser>((ref) {
  final user = ref.watch(authControllerProvider).user ??
      ref.read(authControllerProvider.notifier).lastUser;
  if (user == null) throw StateError('No signed-in user');
  return user;
});

/// Signed-in user id. Data providers watch this so their caches are thrown
/// away when the account changes and never leak between users.
final sessionUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider.select((s) => s.user?.id)),
);
