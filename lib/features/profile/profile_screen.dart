import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/common.dart';
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

    final items = <(IconData, String, String?, VoidCallback)>[
      (Icons.person_outline_rounded, 'Personal information', user.phone ?? 'Add your phone number',
          () => context.push('$base/personal')),
      if (user.isDoctor) ...[
        (Icons.medical_information_outlined, 'Professional profile',
            'Fee, bio, hospital, consultation length',
            () => context.push(Routes.doctorProfessional)),
        (Icons.verified_outlined, 'Verification documents', 'License and ID',
            () => context.push(Routes.doctorDocuments)),
      ] else ...[
        (Icons.favorite_border_rounded, 'Health information',
            [if (user.bloodGroup != null) 'Blood ${user.bloodGroup}', if (user.allergies.isNotEmpty) 'Allergies'].join(' · ').ifEmpty('Blood group, allergies'),
            () => context.push(Routes.healthInfo)),
        (Icons.home_outlined, 'Home service requests', null,
            () => context.push(Routes.serviceRequests)),
      ],
      (Icons.lock_outline_rounded, 'Change password', null, () => changePassword(context, ref)),
      (Icons.help_outline_rounded, 'Help & support', null, () => _help(context)),
    ];

    return PageScaffold(
      title: 'Profile',
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
                      const Chip(
                        avatar: Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                        label: Text('Verified doctor'),
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
          label: const Text('Sign out'),
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
              Text('Help & support',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Questions about bookings, payments or your account? Email us and '
                'we will get back to you.',
              ),
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
                title: const Text('Medical emergency?'),
                subtitle: const Text('Do not wait for support. Call emergency services.'),
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
