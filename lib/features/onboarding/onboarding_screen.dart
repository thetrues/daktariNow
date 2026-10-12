import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/common.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Breakpoints.isMobile(context);
    final intro = _Intro(mobile: mobile);
    const hero = _Hero();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ContentConstraint(
                maxWidth: 1100,
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandLogo(),
                          const SizedBox(height: 32),
                          intro,
                          const SizedBox(height: 24),
                          hero,
                          const SizedBox(height: 24),
                          const _Features(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandLogo(),
                          const SizedBox(height: 48),
                          Row(
                            children: [
                              Expanded(child: intro),
                              const SizedBox(width: 48),
                              const Expanded(child: hero),
                            ],
                          ),
                          const SizedBox(height: 48),
                          const _Features(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Health\nOur Priority',
          style: (mobile ? text.headlineMedium : text.displaySmall)
              ?.copyWith(fontWeight: FontWeight.w700, height: 1.15),
        ),
        const SizedBox(height: 12),
        Text(
          'Talk to a verified specialist by chat, phone or video. '
          'Advanced healthcare for a better and healthier you.',
          style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go(Routes.register),
              icon: const Icon(Icons.arrow_forward_rounded),
              iconAlignment: IconAlignment.end,
              label: const Text('Get Started'),
              style: FilledButton.styleFrom(minimumSize: const Size(180, 52)),
            ),
            OutlinedButton(
              onPressed: () => context.go(Routes.login),
              style: OutlinedButton.styleFrom(minimumSize: const Size(140, 52)),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 90,
                color: AppColors.primary,
              ),
            ),
            const Positioned(
              top: 24,
              right: 24,
              child: _FloatingChip(
                icon: Icons.favorite_rounded,
                color: AppColors.accent,
                label: '72 bpm',
              ),
            ),
            const Positioned(
              bottom: 24,
              left: 24,
              child: _FloatingChip(
                icon: Icons.verified_user_rounded,
                color: AppColors.primary,
                label: 'Trusted by 2M+ users',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.person_search_rounded, 'Find Doctors', AppColors.primary,
          AppColors.primarySoft),
      (Icons.event_available_rounded, 'Book Appointment', AppColors.accent,
          AppColors.accentSoft),
      (Icons.support_agent_rounded, '24/7 Support', AppColors.purple,
          AppColors.purpleSoft),
    ];
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (icon, label, fg, bg) in items)
            Column(
              children: [
                IconBadge(icon: icon, color: fg, background: bg, size: 52),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
        ],
      ),
    );
  }
}
