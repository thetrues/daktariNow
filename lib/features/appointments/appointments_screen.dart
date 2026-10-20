import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../core/data/repositories.dart';
import '../../core/models/consultation.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/consultation_card.dart';
import 'appointment_providers.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    final scope =
        _upcoming ? ConsultationScope.upcoming : ConsultationScope.past;
    final consultations = ref.watch(consultationsProvider(scope));
    final l = context.l10n;
    return PageScaffold(
      title: l.navAppointments,
      children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(l.upcoming)),
            ButtonSegment(value: false, label: Text(l.past)),
          ],
          selected: {_upcoming},
          onSelectionChanged: (s) => setState(() => _upcoming = s.first),
        ),
        const SizedBox(height: 16),
        AsyncView<List<Consultation>>(
          value: consultations,
          onRetry: () => ref.invalidate(consultationsProvider(scope)),
          builder: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(_upcoming
                        ? l.noUpcomingAppointmentsDot
                        : l.noPastAppointments),
                    if (_upcoming) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push(Routes.doctors),
                        child: Text(l.findADoctor),
                      ),
                    ],
                  ],
                ),
              );
            }
            return ResponsiveGrid(
              minItemWidth: 380,
              children: [
                for (final c in items)
                  ConsultationCard(
                    consultation: c,
                    viewerIsDoctor: false,
                    onTap: () => context.push(Routes.consultation(c.id)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
