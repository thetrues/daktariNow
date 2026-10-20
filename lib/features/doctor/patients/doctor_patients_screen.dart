import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/locale_controller.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/repositories.dart';
import '../../../core/models/consultation.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/common.dart';
import '../../appointments/appointment_providers.dart';

class DoctorPatientsScreen extends ConsumerStatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  ConsumerState<DoctorPatientsScreen> createState() =>
      _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends ConsumerState<DoctorPatientsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final consultations = ref.watch(consultationsProvider(ConsultationScope.all));
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    return PageScaffold(
      title: l.myPatients,
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: l.searchPatients,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        AsyncView(
          value: consultations,
          onRetry: () => refreshConsultations(ref),
          builder: (items) {
            // Most recent consultation per patient.
            final latest = <String, Consultation>{};
            for (final c in items) {
              final seen = latest[c.patientId];
              if (seen == null || c.scheduledAt.isAfter(seen.scheduledAt)) {
                latest[c.patientId] = c;
              }
            }
            final patients = latest.values
                .where((c) => c.patientName.toLowerCase().contains(_query))
                .toList()
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
            if (patients.isEmpty) {
              return AppCard(child: Text(l.noPatientsYet));
            }
            return AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final c in patients)
                    ListTile(
                      leading: Avatar.fromName(c.patientName, size: 42),
                      title: Text(c.patientName,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${c.reason ?? l.consultation} · '
                        '${DateFormat('d MMM').format(c.scheduledAt)} · '
                        '${c.status.label(l)}',
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(Routes.consultation(c.id)),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
