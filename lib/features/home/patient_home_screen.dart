import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/health.dart';
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
    final text = Theme.of(context).textTheme;
    final wide = !Breakpoints.isMobile(context);

    final unread = buildNotifications(
      consultations.value ?? const [],
      ref.watch(prescriptionsProvider).value ?? const [],
      ref.watch(serviceRequestsProvider).value ?? const [],
    ).length;

    final health = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Health Overview',
            onViewAll: () => context.push(Routes.health)),
        const _HealthOverview(),
      ],
    );

    final upcoming = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Upcoming Appointment',
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
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.event_available_rounded,
                      color: AppColors.primary),
                  title: Text('No upcoming appointments'),
                  subtitle: Text('Find a doctor and book one'),
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
        const SectionHeader('Quick Actions'),
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
                  Text('Dashboard',
                      style: text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    'Good ${_greeting()}, ${user.firstName} 👋',
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Notifications',
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
          decoration: const InputDecoration(
            hintText: 'Search doctors, specialists...',
            prefixIcon: Icon(Icons.search_rounded),
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

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

/// The patient's own latest readings; an invitation to add some when empty.
class _HealthOverview extends ConsumerWidget {
  const _HealthOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      Text('Track your health',
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        'Add heart rate, blood pressure or sugar readings. '
                        'Your doctor sees them during consultations.',
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
                        Text('Heart Rate',
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
                                ? 'No reading yet'
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
                Text(type.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
                Text(reading?.display ?? 'Add',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: reading == null ? AppColors.primary : null,
                    )),
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
    final actions = [
      (Icons.biotech_outlined, 'Lab Test', AppColors.primary,
          AppColors.primarySoft, () => context.push(Routes.labTests)),
      (Icons.medication_outlined, 'Medicines', AppColors.purple,
          AppColors.purpleSoft, () => context.push(Routes.prescriptions)),
      (Icons.description_outlined, 'Reports', AppColors.amber,
          AppColors.amberSoft, () => context.go(Routes.records)),
      (Icons.emergency_outlined, 'Emergency', AppColors.danger,
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
        SectionHeader('Care at Home', onViewAll: () => context.push(Routes.services)),
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
