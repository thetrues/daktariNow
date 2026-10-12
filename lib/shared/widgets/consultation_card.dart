import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/consultation.dart';
import 'avatar.dart';
import 'common.dart';

/// Appointment card. Shows the doctor to patients and the patient to doctors.
class ConsultationCard extends StatelessWidget {
  const ConsultationCard({
    super.key,
    required this.consultation,
    required this.viewerIsDoctor,
    this.onTap,
    this.trailing,
  });

  final Consultation consultation;
  final bool viewerIsDoctor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = consultation;
    final name = viewerIsDoctor ? c.patientName : c.doctorName;
    final subtitle =
        viewerIsDoctor ? (c.reason ?? 'Consultation') : c.doctorSpecialty;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Avatar.fromName(name, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (!c.isUpcoming || c.isOverdue()) ...[
                      const SizedBox(width: 8),
                      _StatusPill(c.status, overdue: c.isOverdue()),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      text.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _Meta(
                      icon: Icons.calendar_today_rounded,
                      label: DateFormat('d MMM yyyy').format(c.scheduledAt),
                    ),
                    _Meta(
                      icon: Icons.schedule_rounded,
                      label: DateFormat('h:mm a').format(c.scheduledAt),
                    ),
                    _Meta(icon: c.type.icon, label: c.type.label),
                  ],
                ),
              ],
            ),
          ),
          trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status, {this.overdue = false});

  final ConsultationStatus status;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final cancelled = status == ConsultationStatus.cancelled || overdue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cancelled ? AppColors.accentSoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        overdue ? 'Not started' : status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cancelled ? AppColors.danger : AppColors.primaryDark,
            ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
