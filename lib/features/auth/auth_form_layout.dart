import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/language_switcher.dart';

/// Centered card on web, full-screen form on phones.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mobile = Breakpoints.isMobile(context);
    final text = Theme.of(context).textTheme;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: context.l10n.back,
              onPressed: () => context.go(Routes.welcome),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            // Just the mark on narrow phones, so the language switch fits.
            BrandLogo(showName: MediaQuery.sizeOf(context).width >= 400),
            const Spacer(),
            const LanguageSwitcher(),
          ],
        ),
        const SizedBox(height: 28),
        Text(title,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 28),
        child,
      ],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: mobile
                    ? form
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.all(36),
                          child: form,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
