import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    return PageScaffold(
      title: 'Appointments',
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Upcoming')),
            ButtonSegment(value: false, label: Text('Past')),
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
                        ? 'No upcoming appointments.'
                        : 'No past appointments.'),
                    if (_upcoming) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push(Routes.doctors),
                        child: const Text('Find a doctor'),
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
