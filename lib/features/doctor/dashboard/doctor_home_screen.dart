import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/layout/breakpoints.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/repositories.dart';
import '../../../core/format.dart';
import '../../../core/models/consultation.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/consultation_card.dart';
import '../../appointments/appointment_providers.dart';
import '../../auth/auth_controller.dart';
import '../doctor_providers.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final online = ref.watch(presenceProvider);
    final upcoming = ref.watch(consultationsProvider(ConsultationScope.upcoming));
    final wallet = ref.watch(walletSummaryProvider);
    final profile = ref.watch(doctorProfileProvider);
    final text = Theme.of(context).textTheme;

    Future<void> setOnline(bool v) async {
      try {
        await ref.read(presenceProvider.notifier).set(v);
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        refreshConsultations(ref);
        ref.invalidate(walletSummaryProvider);
        ref.invalidate(doctorProfileProvider);
      },
      child: PageScaffold(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good day, ${user.name}',
                      style: text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                      style: text.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle,
                        size: 10,
                        color: online.value == true
                            ? AppColors.success
                            : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(online.value == true ? 'Available' : 'Offline'),
                    const SizedBox(width: 8),
                    Switch(
                      value: online.value ?? false,
                      onChanged: online.hasValue ? setOnline : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ResponsiveGrid(
            minItemWidth: 200,
            children: [
              _StatTile(
                icon: Icons.event_note_rounded,
                label: 'Upcoming',
                value: upcoming.whenOrNull(data: (l) => '${l.length}') ?? '…',
                color: AppColors.primary,
                background: AppColors.primarySoft,
              ),
              _StatTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Earned this month',
                value: wallet.whenOrNull(
                        data: (w) => money(w.thisMonthCents, w.currency)) ??
                    '…',
                color: AppColors.success,
                background: const Color(0xFFE5F8F0),
              ),
              _StatTile(
                icon: Icons.star_rounded,
                label: 'Rating',
                value: profile.whenOrNull(
                        data: (p) => (p['rating'] as num).toStringAsFixed(1)) ??
                    '…',
                color: AppColors.amber,
                background: AppColors.amberSoft,
              ),
              _StatTile(
                icon: Icons.task_alt_rounded,
                label: 'Completed',
                value: wallet.whenOrNull(
                        data: (w) => '${w.completedConsultations}') ??
                    '…',
                color: AppColors.purple,
                background: AppColors.purpleSoft,
              ),
            ],
          ),
          const SectionHeader('Upcoming consultations'),
          AsyncView(
            value: upcoming,
            onRetry: () => refreshConsultations(ref),
            builder: (items) => items.isEmpty
                ? const AppCard(child: Text('No consultations scheduled.'))
                : ResponsiveGrid(
                    minItemWidth: Breakpoints.isDesktop(context) ? 480 : 380,
                    children: [
                      for (final c in items)
                        ConsultationCard(
                          consultation: c,
                          viewerIsDoctor: true,
                          onTap: () => context.push(Routes.consultation(c.id)),
                          trailing: FilledButton.tonal(
                            onPressed: () =>
                                context.push(Routes.consultation(c.id)),
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 40)),
                            child: Text(
                              c.status == ConsultationStatus.inProgress
                                  ? 'Resume'
                                  : 'Open',
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, background: background),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style:
                        text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
