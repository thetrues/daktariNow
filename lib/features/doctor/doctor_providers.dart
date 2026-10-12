import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/repositories.dart';
import '../../core/models/wallet.dart';
import '../auth/auth_controller.dart';

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(walletRepositoryProvider).summary();
});

final walletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(walletRepositoryProvider).transactions();
});

final doctorProfileProvider = FutureProvider<Map<String, dynamic>>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(doctorSelfRepositoryProvider).profile();
});

final availabilityProvider = FutureProvider<List<AvailabilityWindow>>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(doctorSelfRepositoryProvider).availability();
});

/// Online/offline toggle. Starts from the server value; changes are saved
/// immediately and rolled back if the save fails.
class PresenceController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      (await ref.watch(doctorProfileProvider.future))['isOnline'] as bool? ??
      false;

  Future<void> set(bool online) async {
    final previous = state.value ?? false;
    state = AsyncData(online);
    try {
      await ref.read(doctorSelfRepositoryProvider).setPresence(online);
    } catch (e, st) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(e, st);
    }
  }
}

final presenceProvider =
    AsyncNotifierProvider<PresenceController, bool>(PresenceController.new);
