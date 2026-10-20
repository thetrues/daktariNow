import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/locale_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_errors.dart';
import '../../../core/models/app_user.dart';
import '../../../shared/widgets/common.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../auth/auth_controller.dart';
import '../../profile/profile_forms.dart';
import '../doctor_providers.dart';

/// Shown to doctors until an admin approves them in the admin console.
class PendingVerificationScreen extends ConsumerStatefulWidget {
  const PendingVerificationScreen({super.key});

  @override
  ConsumerState<PendingVerificationScreen> createState() =>
      _PendingVerificationScreenState();
}

class _PendingVerificationScreenState
    extends ConsumerState<PendingVerificationScreen> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      // If approved, the router moves the doctor into their workspace.
      await ref.read(authControllerProvider.notifier).reloadUser();
      ref.invalidate(doctorProfileProvider);
      final user = ref.read(authControllerProvider).user;
      if (mounted && user != null && !user.isVerifiedDoctor) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.stillUnderReview)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiException.from(e).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(doctorProfileProvider);
    final status = user.verificationStatus;
    final blocked = status == VerificationStatus.rejected ||
        status == VerificationStatus.suspended;
    final reason = profile.value?['rejectionReason'] as String?;
    final docCount = (profile.value?['documents'] as List?)?.length ?? 0;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    final steps = [
      (l.stepAccountCreated, true),
      (l.stepUploadDocs, docCount > 0),
      (l.stepAdminReview, false),
      (l.stepStartConsulting, false),
    ];

    return PageScaffold(
      title: l.verification,
      actions: [
        const LanguageSwitcher(),
        TextButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: Text(l.signOut),
        ),
      ],
      children: [
        const SizedBox(height: 16),
        Center(
          child: IconBadge(
            icon: blocked
                ? Icons.error_outline_rounded
                : Icons.hourglass_top_rounded,
            color: blocked ? AppColors.danger : AppColors.amber,
            background: blocked ? AppColors.accentSoft : AppColors.amberSoft,
            size: 88,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          switch (status) {
            VerificationStatus.rejected => l.verificationDeclined,
            VerificationStatus.suspended => l.accountSuspended,
            _ => l.profileUnderReview,
          },
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          blocked ? l.blockedBody(user.name) : l.reviewBody(user.name),
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        if (blocked && reason != null) ...[
          const SizedBox(height: 16),
          _Narrow(
            child: AppCard(
              color: AppColors.accentSoft,
              child: Text(l.reasonValue(reason)),
            ),
          ),
        ],
        const SizedBox(height: 28),
        if (!blocked)
          _Narrow(
            child: AppCard(
              child: Column(
                children: [
                  for (final (label, done) in steps)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: done ? AppColors.success : AppColors.textMuted,
                      ),
                      title: Text(label),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        _Narrow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _checking ? null : _check,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.checkStatus),
              ),
              if (!blocked) ...[
                SectionHeader(l.yourDocuments),
                const DoctorDocuments(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Narrow extends StatelessWidget {
  const _Narrow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: child,
        ),
      );
}
