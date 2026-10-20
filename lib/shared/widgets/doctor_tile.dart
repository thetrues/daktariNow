import 'package:flutter/material.dart';

import '../../app/locale_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../core/format.dart';
import '../../core/models/doctor.dart';
import 'avatar.dart';
import 'common.dart';

class DoctorTile extends StatelessWidget {
  const DoctorTile({super.key, required this.doctor, this.onTap});

  final Doctor doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: AppColors.textSecondary);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Avatar.fromName(doctor.name, size: 60, online: doctor.isOnline),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(doctor.specialty, style: muted),
                const SizedBox(height: 4),
                RatingRow(rating: doctor.rating, reviews: doctor.reviews),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.work_outline_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${doctor.yearsExperience}+ Years Exp.', style: muted),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(doctor.feeCents, doctor.currency),
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(context.l10n.book),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
