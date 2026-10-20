import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/api/api_errors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/consultation.dart';
import '../../core/models/health.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/common.dart';
import '../appointments/appointment_providers.dart';
import '../auth/auth_controller.dart';

final prescriptionsProvider = FutureProvider<List<PatientPrescription>>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(recordRepositoryProvider).prescriptions();
});

final labRequestsProvider = FutureProvider<List<PatientLabRequest>>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(recordRepositoryProvider).labRequests();
});

final serviceRequestsProvider = FutureProvider<List<ServiceRequest>>((ref) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(serviceRequestRepositoryProvider).mine();
});

/// "Medicines": every prescription the patient has received.
class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: AppColors.textSecondary);
    final l = context.l10n;
    return PageScaffold(
      title: l.myMedicines,
      showBack: true,
      children: [
        AsyncView(
          value: ref.watch(prescriptionsProvider),
          onRetry: () => ref.invalidate(prescriptionsProvider),
          builder: (list) => list.isEmpty
              ? _Empty(
                  icon: Icons.medication_outlined,
                  title: l.noPrescriptionsYet,
                  body: l.noPrescriptionsBody,
                )
              : Column(
                  children: [
                    for (final p in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          onTap: () => context.push(Routes.consultation(p.consultationId)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(p.doctorName,
                                        style: text.titleSmall
                                            ?.copyWith(fontWeight: FontWeight.w600)),
                                  ),
                                  Text(DateFormat('d MMM yyyy').format(p.createdAt), style: muted),
                                ],
                              ),
                              Text(p.specialty, style: muted),
                              const Divider(height: 20),
                              for (final item in p.items)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.medication_rounded,
                                          size: 20, color: AppColors.primary),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.medicine,
                                                style: text.bodyMedium
                                                    ?.copyWith(fontWeight: FontWeight.w600)),
                                            Text('${item.dosage} · ${item.duration}', style: muted),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (p.notes?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 6),
                                Text(p.notes!, style: muted),
                              ],
                            ],
                          ),
                        ),
                      ),
                    Text(
                      l.takeAsDirected,
                      style: text.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// "Lab Test": tests doctors have requested.
class LabTestsScreen extends ConsumerWidget {
  const LabTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: AppColors.textSecondary);
    final hasSampleCollection = ref.watch(servicesProvider).value?.any(
              (s) => s.name.toLowerCase().contains('sample'),
            ) ??
        false;
    final l = context.l10n;

    return PageScaffold(
      title: l.labTests,
      showBack: true,
      children: [
        AsyncView(
          value: ref.watch(labRequestsProvider),
          onRetry: () => ref.invalidate(labRequestsProvider),
          builder: (list) => list.isEmpty
              ? _Empty(
                  icon: Icons.biotech_outlined,
                  title: l.noLabTests,
                  body: l.noLabTestsBody,
                )
              : AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final r in list)
                        ListTile(
                          leading: const IconBadge(icon: Icons.biotech_outlined, size: 40),
                          title: Text(r.testName,
                              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            l.requestedBy(r.doctorName,
                                DateFormat('d MMM yyyy').format(r.createdAt)),
                            style: muted,
                          ),
                          trailing: _StatusPill(
                            labStatusLabel(l, r.status),
                            done: r.status == 'COMPLETED',
                          ),
                          onTap: () => context.push(Routes.consultation(r.consultationId)),
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        if (hasSampleCollection)
          AppCard(
            onTap: () => context.push(Routes.services),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const IconBadge(icon: Icons.home_outlined),
              title: Text(l.samplesAtHome),
              subtitle: Text(l.requestSampleCollection),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

}

/// Lab request statuses from the API (LabRequestStatus).
String labStatusLabel(AppLocalizations l, String status) => switch (status) {
      'REQUESTED' => l.labToDo,
      'SAMPLE_COLLECTED' => l.labSampleCollected,
      'COMPLETED' => l.statusCompleted,
      'CANCELLED' => l.statusCancelled,
      _ => status,
    };

/// Tanzania's national emergency number. Confirm before launch.
const emergencyNumber = '112';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _call(BuildContext context) async {
    final ok = await launchUrl(Uri(scheme: 'tel', path: emergencyNumber));
    if (!ok && context.mounted) {
      showInfo(context, context.l10n.dialFromPhone(emergencyNumber));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    return PageScaffold(
      title: l.emergency,
      showBack: true,
      children: [
        AppCard(
          color: AppColors.accentSoft,
          child: Column(
            children: [
              const IconBadge(
                icon: Icons.emergency_rounded,
                color: AppColors.danger,
                background: Colors.white,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(l.isThisEmergency,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                l.emergencyBody,
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                  onPressed: () => _call(context),
                  icon: const Icon(Icons.call_rounded),
                  label: Text(l.callNumber(emergencyNumber)),
                ),
              ),
            ],
          ),
        ),
        SectionHeader(l.whileYouWait),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Step(l.waitStep1),
              _Step(l.waitStep2),
              _Step(l.waitStep3),
              _Step(l.waitStep4),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

/// In-app notifications, built from real activity until push arrives.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(consultationsProvider(ConsultationScope.upcoming));
    final prescriptions = ref.watch(prescriptionsProvider);
    final requests = ref.watch(serviceRequestsProvider);
    final l = context.l10n;
    final items = buildNotifications(
      upcoming.value ?? const [],
      prescriptions.value ?? const [],
      requests.value ?? const [],
      l10n: l,
    );
    final loading = upcoming.isLoading || prescriptions.isLoading || requests.isLoading;

    return PageScaffold(
      title: l.notifications,
      showBack: true,
      children: [
        if (loading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          _Empty(
            icon: Icons.notifications_none_rounded,
            title: l.allCaughtUp,
            body: l.allCaughtUpBody,
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final n in items)
                  ListTile(
                    leading: IconBadge(icon: n.icon, color: n.color,
                        background: n.color.withValues(alpha: 0.12), size: 40),
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    onTap: () => context.push(n.route),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class AppNotification {
  const AppNotification(this.title, this.body, this.icon, this.color, this.route, this.at);

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final String route;
  final DateTime at;
}

/// Upcoming consultations in the next 48 hours, prescriptions from the last
/// two weeks, and home-service requests the team has updated.
List<AppNotification> buildNotifications(
  List<Consultation> upcoming,
  List<PatientPrescription> prescriptions,
  List<ServiceRequest> requests, {
  DateTime? now,
  AppLocalizations? l10n,
}) {
  final l = l10n ?? currentL10n;
  final t = now ?? DateTime.now();
  final fmt = DateFormat('EEE d MMM, h:mm a');
  final list = <AppNotification>[
    for (final c in upcoming)
      if (c.status == ConsultationStatus.inProgress)
        AppNotification(l.notifStarted(c.doctorName),
            l.tapToJoin, c.type.icon, AppColors.success,
            Routes.consultation(c.id), c.scheduledAt)
      else if (c.scheduledAt.isAfter(t) &&
          c.scheduledAt.difference(t) <= const Duration(hours: 48))
        AppNotification(l.notifUpcoming(c.type.label(l), c.doctorName),
            fmt.format(c.scheduledAt), Icons.event_rounded, AppColors.primary,
            Routes.consultation(c.id), c.scheduledAt),
    for (final p in prescriptions)
      if (t.difference(p.createdAt) <= const Duration(days: 14))
        AppNotification(l.notifPrescription(p.doctorName),
            p.items.map((i) => i.medicine).join(', '),
            Icons.medication_rounded, AppColors.purple, Routes.prescriptions, p.createdAt),
    for (final r in requests)
      if (r.status != ServiceRequestStatus.requested &&
          t.difference(r.updatedAt) <= const Duration(days: 14))
        AppNotification(
            l.notifServiceUpdate(r.serviceName, r.status.label(l).toLowerCase()),
            r.adminNote ?? fmt.format(r.preferredAt),
            Icons.home_outlined, AppColors.amber, Routes.serviceRequests, r.updatedAt),
  ]..sort((a, b) => b.at.compareTo(a.at));
  return list;
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            IconBadge(icon: icon, size: 56),
            const SizedBox(height: 12),
            Text(title, style: text.titleSmall),
            const SizedBox(height: 4),
            Text(body,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label, {this.done = false});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFE5F8F0) : AppColors.amberSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: done ? AppColors.success : const Color(0xFF9A6200),
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}
