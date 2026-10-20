import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/language_switcher.dart';
import '../auth/auth_controller.dart';
import 'profile_forms.dart';

/// Support contact shown in the app. Replace with the real inbox/number.
const supportEmail = 'support@daktarinow.com';

/// Shared by patients and doctors; doctor-only rows appear for doctors.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final text = Theme.of(context).textTheme;
    final base = user.isDoctor ? Routes.doctorProfile : Routes.profile;
    final l = context.l10n;

    final items = <(IconData, String, String?, VoidCallback)>[
      (Icons.person_outline_rounded, l.personalInformation, user.phone ?? l.addPhoneNumber,
          () => context.push('$base/personal')),
      if (user.isDoctor) ...[
        (Icons.medical_information_outlined, l.professionalProfile,
            l.professionalProfileHint,
            () => context.push(Routes.doctorProfessional)),
        (Icons.verified_outlined, l.verificationDocuments, l.licenseAndId,
            () => context.push(Routes.doctorDocuments)),
      ] else ...[
        (Icons.favorite_border_rounded, l.healthInformation,
            [
              if (user.bloodGroup != null) l.bloodGroupValue(user.bloodGroup!),
              if (user.allergies.isNotEmpty) l.allergies,
            ].join(' · ').ifEmpty(l.bloodGroupAllergies),
            () => context.push(Routes.healthInfo)),
        (Icons.home_outlined, l.homeServiceRequests, null,
            () => context.push(Routes.serviceRequests)),
      ],
      (Icons.lock_outline_rounded, l.changePassword, null, () => changePassword(context, ref)),
      (Icons.help_outline_rounded, l.helpSupport, null, () => _help(context)),
    ];

    return PageScaffold(
      title: l.navProfile,
      children: [
        AppCard(
          child: Row(
            children: [
              Avatar(initials: user.initials, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(user.email,
                        style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    if (user.isVerifiedDoctor) ...[
                      const SizedBox(height: 6),
                      Chip(
                        avatar: const Icon(Icons.verified_rounded,
                            size: 16, color: AppColors.primary),
                        label: Text(l.verifiedDoctor),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.translate_rounded, color: AppColors.primary),
                title: Text(l.language),
                trailing: const LanguageSwitcher(),
              ),
              for (final (icon, label, subtitle, onTap) in items)
                ListTile(
                  leading: Icon(icon, color: AppColors.primary),
                  title: Text(label),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onTap,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: Text(l.signOut),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _help(BuildContext context) {
    final l = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.helpSupport,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l.helpBody),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                title: const Text(supportEmail),
                onTap: () => launchUrl(Uri(scheme: 'mailto', path: supportEmail)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.emergency_outlined, color: AppColors.danger),
                title: Text(l.medicalEmergency),
                subtitle: Text(l.emergencyDontWait),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(Routes.emergency);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
