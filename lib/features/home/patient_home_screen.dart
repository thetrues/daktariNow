import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/health.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/consultation_card.dart';
import '../../shared/widgets/mini_charts.dart';
import '../appointments/appointment_providers.dart';
import '../auth/auth_controller.dart';
import '../care/care_screens.dart';
import '../health_status/health_providers.dart';
import '../services/services_screens.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final consultations =
        ref.watch(consultationsProvider(ConsultationScope.upcoming));
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final wide = !Breakpoints.isMobile(context);

    final unread = buildNotifications(
      consultations.value ?? const [],
      ref.watch(prescriptionsProvider).value ?? const [],
      ref.watch(serviceRequestsProvider).value ?? const [],
      l10n: context.l10n,
    ).length;

    final health = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.healthOverview,
            onViewAll: () => context.push(Routes.health)),
        const _HealthOverview(),
      ],
    );

    final upcoming = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.upcomingAppointment,
            onViewAll: () => context.go(Routes.appointments)),
        AsyncView(
          value: consultations,
          onRetry: () => refreshConsultations(ref),
          builder: (items) {
            final next =
                items.where((c) => c.isUpcoming && !c.isOverdue()).firstOrNull;
            if (next == null) {
              return AppCard(
                onTap: () => context.push(Routes.doctors),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available_rounded,
                      color: AppColors.primary),
                  title: Text(l.noUpcomingAppointments),
                  subtitle: Text(l.findAndBook),
                ),
              );
            }
            return ConsultationCard(
              consultation: next,
              viewerIsDoctor: false,
              onTap: () => context.push(Routes.consultation(next.id)),
            );
          },
        ),
        SectionHeader(l.quickActions),
        const _QuickActions(),
      ],
    );

    return PageScaffold(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.navDashboard,
                      style: text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    _greeting(l, user.firstName),
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: l.notifications,
              onPressed: () => context.push(Routes.notifications),
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          onTap: () => context.push(Routes.doctors),
          decoration: InputDecoration(
            hintText: l.searchDoctorsHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: health),
              const SizedBox(width: 24),
              Expanded(child: upcoming),
            ],
          )
        else ...[
          health,
          upcoming,
        ],
        const _HomeServices(),
        const SizedBox(height: 24),
      ],
    );
  }

  static String _greeting(AppLocalizations l, String name) {
    final h = DateTime.now().hour;
    if (h < 12) return l.greetingMorning(name);
    if (h < 17) return l.greetingAfternoon(name);
    return l.greetingEvening(name);
  }
}

/// The patient's own latest readings; an invitation to add some when empty.
class _HealthOverview extends ConsumerWidget {
  const _HealthOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final latest = ref.watch(latestVitalsProvider);
    final hrHistory = ref.watch(vitalHistoryProvider(VitalType.heartRate)).value ?? const [];

    return AsyncView(
      value: latest,
      onRetry: () => refreshVitals(ref),
      builder: (byType) {
        if (byType.isEmpty) {
          return AppCard(
            onTap: () => addVitalReading(context, ref),
            child: Row(
              children: [
                const IconBadge(
                  icon: Icons.monitor_heart_outlined,
                  color: AppColors.accent,
                  background: AppColors.accentSoft,
                  size: 56,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.trackYourHealth,
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        l.trackYourHealthBody,
                        style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
              ],
            ),
          );
        }
        final hr = byType[VitalType.heartRate];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              onTap: () => context.push(Routes.health),
              child: Row(
                children: [
                  const IconBadge(
                    icon: Icons.favorite_rounded,
                    color: AppColors.accent,
                    background: AppColors.accentSoft,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(VitalType.heartRate.label(l),
                            style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        Text.rich(
                          TextSpan(
                            text: hr == null ? '— ' : '${hr.display} ',
                            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                            children: [
                              TextSpan(
                                text: 'bpm',
                                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (hrHistory.length >= 2)
                          SizedBox(
                            height: 36,
                            child: Sparkline(
                              values: [for (final r in hrHistory.reversed) r.value],
                              color: AppColors.accent,
                            ),
                          )
                        else
                          Text(
                            hr == null
                                ? l.noReadingYet
                                : DateFormat('d MMM, h:mm a').format(hr.recordedAt),
                            style: text.labelSmall?.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _VitalCard(type: VitalType.bloodPressure, reading: byType[VitalType.bloodPressure])),
                const SizedBox(width: 12),
                Expanded(child: _VitalCard(type: VitalType.bloodSugar, reading: byType[VitalType.bloodSugar])),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _VitalCard extends ConsumerWidget {
  const _VitalCard({required this.type, this.reading});

  final VitalType type;
  final VitalReading? reading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: reading == null
          ? () => addVitalReading(context, ref, initial: type)
          : () => context.push(Routes.health),
      child: Row(
        children: [
          IconBadge(icon: type.icon, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label(context.l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
                // Scale down rather than wrap in narrow cards.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(reading?.display ?? context.l10n.add,
                      maxLines: 1,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: reading == null ? AppColors.primary : null,
                      )),
                ),
                Text(type.unit,
                    style: text.labelSmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final actions = [
      (Icons.biotech_outlined, l.labTest, AppColors.primary,
          AppColors.primarySoft, () => context.push(Routes.labTests)),
      (Icons.medication_outlined, l.medicines, AppColors.purple,
          AppColors.purpleSoft, () => context.push(Routes.prescriptions)),
      (Icons.description_outlined, l.reports, AppColors.amber,
          AppColors.amberSoft, () => context.go(Routes.records)),
      (Icons.emergency_outlined, l.emergency, AppColors.danger,
          AppColors.accentSoft, () => context.push(Routes.emergency)),
    ];

    return Row(
      children: [
        for (final (icon, label, fg, bg, onTap) in actions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppCard(
                onTap: onTap,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    IconBadge(icon: icon, color: fg, background: bg),
                    const SizedBox(height: 8),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeServices extends ConsumerWidget {
  const _HomeServices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider).value ?? const [];
    if (services.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.l10n.careAtHome, onViewAll: () => context.push(Routes.services)),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 220,
              child: ServiceCard(service: services[i], compact: true),
            ),
          ),
        ),
      ],
    );
  }
}
