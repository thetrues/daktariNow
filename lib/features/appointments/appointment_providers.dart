import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/repositories.dart';
import '../../core/models/consultation.dart';
import '../auth/auth_controller.dart';

/// The signed-in user's consultations (the API scopes by role).
final consultationsProvider =
    FutureProvider.family<List<Consultation>, ConsultationScope>(
  (ref, scope) {
    ref.watch(sessionUserIdProvider);
    return ref.watch(consultationRepositoryProvider).list(scope);
  },
);

final consultationDetailProvider =
    FutureProvider.autoDispose.family<ConsultationDetail, String>(
  (ref, id) => ref.watch(consultationRepositoryProvider).byId(id),
);

/// Call after anything that changes consultations.
void refreshConsultations(WidgetRef ref) => ref.invalidate(consultationsProvider);
