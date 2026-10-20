import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../shared/widgets/logo_mark.dart';

/// Public landing page at app.daktarinow.com for signed-out visitors.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _scroll = ScrollController();
  final _howKey = GlobalKey();
  final _doctorsKey = GlobalKey();
  final _faqKey = GlobalKey();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final scrolled = _scroll.offset > 8;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = _Layout(width);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _NavBar(
            layout: layout,
            elevated: _scrolled,
            onHow: () => _goTo(_howKey),
            onDoctors: () => _goTo(_doctorsKey),
            onFaq: () => _goTo(_faqKey),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  _HeroSection(layout: layout),
                  _HowItWorks(key: _howKey, layout: layout),
                  _WaysToConsult(layout: layout),
                  _Specialties(layout: layout),
                  _HomeCare(layout: layout),
                  _ForDoctors(key: _doctorsKey, layout: layout),
                  _Faq(key: _faqKey, layout: layout),
                  _FinalCta(layout: layout),
                  _Footer(layout: layout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Spacing and column decisions for the current width.
class _Layout {
  _Layout(this.width);

  final double width;

  bool get mobile => width < Breakpoints.tablet;
  bool get desktop => width >= 960;
  double get gutter => mobile ? 20 : 32;
  double get sectionGap => mobile ? 56 : 96;
}

/// Width-limited, padded band.
class _Section extends StatelessWidget {
  const _Section({required this.layout, required this.child, this.bottom});

  final _Layout layout;
  final Widget child;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        layout.gutter,
        layout.sectionGap,
        layout.gutter,
        bottom ?? 0,
      ),
      child: ContentConstraint(maxWidth: 1160, child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle, this.eyebrow});

  final String title;
  final String? subtitle;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mobile = Breakpoints.isMobile(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Column(
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              textAlign: TextAlign.center,
              style: text.labelMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: (mobile ? text.headlineSmall : text.headlineMedium)
                ?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.layout,
    required this.elevated,
    required this.onHow,
    required this.onDoctors,
    required this.onFaq,
  });

  final _Layout layout;
  final bool elevated;
  final VoidCallback onHow;
  final VoidCallback onDoctors;
  final VoidCallback onFaq;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final linkStyle = TextButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: elevated ? AppColors.border : Colors.transparent,
          ),
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: layout.gutter,
            vertical: 12,
          ),
          child: ContentConstraint(
            maxWidth: 1160,
            child: Row(
              children: [
                layout.mobile
                    ? const BrandLogo(showName: false, size: 36)
                    : const BrandLogo(size: 36),
                const Spacer(),
                if (layout.desktop) ...[
                  TextButton(
                    style: linkStyle,
                    onPressed: onHow,
                    child: Text(l.navHowItWorks),
                  ),
                  TextButton(
                    style: linkStyle,
                    onPressed: onDoctors,
                    child: Text(l.navForDoctors),
                  ),
                  TextButton(
                    style: linkStyle,
                    onPressed: onFaq,
                    child: Text(l.navFaq),
                  ),
                  const SizedBox(width: 16),
                ],
                const LanguageSwitcher(),
                const SizedBox(width: 8),
                TextButton(
                  style: linkStyle,
                  onPressed: () => context.go(Routes.login),
                  child: Text(l.signIn),
                ),
                if (!layout.mobile) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => context.go(Routes.register),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(l.getStarted),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final copy = _HeroCopy(layout: layout);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
      padding: EdgeInsets.fromLTRB(
        layout.gutter,
        layout.mobile ? 32 : 72,
        layout.gutter,
        layout.mobile ? 48 : 88,
      ),
      child: ContentConstraint(
        maxWidth: 1160,
        child: _FadeSlideIn(
          child: layout.desktop
              ? Row(
                  children: [
                    Expanded(flex: 11, child: copy),
                    const SizedBox(width: 56),
                    const Expanded(flex: 9, child: _HeroVisual()),
                  ],
                )
              : Column(
                  children: [
                    copy,
                    const SizedBox(height: 40),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: const _HeroVisual(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final align = layout.desktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = layout.desktop ? TextAlign.start : TextAlign.center;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l.heroEyebrow,
                  style: text.labelMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l.heroTitle,
          textAlign: textAlign,
          style: (layout.mobile ? text.headlineLarge : text.displayMedium)
              ?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            l.heroSubtitle,
            textAlign: textAlign,
            style: text.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
              fontSize: layout.mobile ? 16 : 18,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: layout.desktop
              ? WrapAlignment.start
              : WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => context.go(Routes.register),
              icon: const Icon(Icons.search_rounded),
              label: Text(l.findADoctor),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('${Routes.register}?as=doctor'),
              icon: const Icon(Icons.medical_services_outlined),
              label: Text(l.iAmADoctor),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                backgroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: layout.desktop
              ? WrapAlignment.start
              : WrapAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: [
            _TrustPoint(Icons.verified_user_outlined, l.trustVerified),
            _TrustPoint(Icons.payments_outlined, l.trustTzs),
            _TrustPoint(Icons.lock_outline_rounded, l.trustPrivate),
          ],
        ),
      ],
    );
  }
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// An illustration of a consultation, built from widgets so it is sharp,
/// translated and light to load.
class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;

    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video area
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2CC3B5), AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _Pill(
                      icon: Icons.videocam_rounded,
                      label: l.mockVideoConsultation,
                      dark: true,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 64,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CallButton(Icons.mic_rounded, Colors.white24),
                        SizedBox(width: 10),
                        _CallButton(Icons.call_end_rounded, AppColors.danger),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySoft,
                child: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.mockSpecialty,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l.mockWhen,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Bubble(text: l.mockDoctorMessage, fromMe: false),
          const SizedBox(height: 8),
          _Bubble(text: l.mockPatientMessage, fromMe: true),
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: card,
        ),
        Positioned(
          right: -8,
          top: 0,
          child: _FloatingBadge(
            icon: Icons.verified_user_rounded,
            color: AppColors.primary,
            label: l.mockVerified,
          ),
        ),
        Positioned(
          left: -8,
          bottom: 0,
          child: _FloatingBadge(
            icon: Icons.medication_rounded,
            color: AppColors.accent,
            label: l.mockPrescriptionReady,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, this.dark = false});

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromMe});

  final String text;
  final bool fromMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fromMe ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromMe ? 16 : 4),
            bottomRight: Radius.circular(fromMe ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: fromMe ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// How it works

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({super.key, required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = [
      (Icons.person_search_rounded, l.step1Title, l.step1Body),
      (Icons.event_available_rounded, l.step2Title, l.step2Body),
      (Icons.health_and_safety_rounded, l.step3Title, l.step3Body),
    ];
    return _Section(
      layout: layout,
      child: Column(
        children: [
          _SectionTitle(
            eyebrow: l.navHowItWorks,
            title: l.howTitle,
            subtitle: l.howSubtitle,
          ),
          const SizedBox(height: 40),
          _Columns(
            layout: layout,
            children: [
              for (final (i, (icon, title, body)) in steps.indexed)
                _StepCard(number: i + 1, icon: icon, title: title, body: body),
            ],
          ),
        ],
      ),
    );
  }
}

/// Three equal columns on wide screens, a stack on phones.
class _Columns extends StatelessWidget {
  const _Columns({required this.layout, required this.children});

  final _Layout layout;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (layout.mobile) {
      return Column(
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            c,
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) const SizedBox(width: 20),
            Expanded(child: c),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int number;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const Spacer(),
              Text(
                '0$number',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: text.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ways to consult

class _WaysToConsult extends StatelessWidget {
  const _WaysToConsult({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ways = [
      (
        Icons.chat_bubble_rounded,
        l.consultChat,
        l.wayChatBody,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      (
        Icons.call_rounded,
        l.consultVoice,
        l.wayVoiceBody,
        AppColors.purple,
        AppColors.purpleSoft,
      ),
      (
        Icons.videocam_rounded,
        l.consultVideo,
        l.wayVideoBody,
        AppColors.accent,
        AppColors.accentSoft,
      ),
    ];
    return _Section(
      layout: layout,
      child: Column(
        children: [
          _SectionTitle(title: l.waysTitle, subtitle: l.waysSubtitle),
          const SizedBox(height: 40),
          _Columns(
            layout: layout,
            children: [
              for (final (icon, title, body, fg, bg) in ways)
                _FeatureCard(
                  icon: icon,
                  title: title,
                  body: body,
                  fg: fg,
                  bg: bg,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.fg,
    required this.bg,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: fg, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: text.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Specialties

class _Specialties extends StatelessWidget {
  const _Specialties({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (Icons.medical_services_rounded, l.specGp),
      (Icons.child_care_rounded, l.specPediatrics),
      (Icons.pregnant_woman_rounded, l.specGynecology),
      (Icons.favorite_rounded, l.specCardiology),
      (Icons.face_retouching_natural_rounded, l.specDermatology),
      (Icons.mood_rounded, l.specDentistry),
      (Icons.psychology_rounded, l.specPsychiatry),
      (Icons.hearing_rounded, l.specEnt),
    ];
    return _Section(
      layout: layout,
      child: Column(
        children: [
          _SectionTitle(
            title: l.specialtiesTitle,
            subtitle: l.specialtiesSubtitle,
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (icon, label) in items)
                Chip(
                  avatar: Icon(icon, size: 18, color: AppColors.primary),
                  label: Text(label),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  shape: const StadiumBorder(),
                ),
              Chip(
                label: Text(l.andManyMore),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                backgroundColor: AppColors.primarySoft,
                side: BorderSide.none,
                labelStyle: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
                shape: const StadiumBorder(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home care

class _HomeCare extends StatelessWidget {
  const _HomeCare({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final services = [
      (
        Icons.home_rounded,
        l.homeVisitTitle,
        l.homeVisitBody,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      (
        Icons.biotech_rounded,
        l.sampleCollectionTitle,
        l.sampleCollectionBody,
        AppColors.purple,
        AppColors.purpleSoft,
      ),
      (
        Icons.vaccines_rounded,
        l.nurseVisitTitle,
        l.nurseVisitBody,
        AppColors.amber,
        AppColors.amberSoft,
      ),
    ];
    return _Section(
      layout: layout,
      child: Column(
        children: [
          _SectionTitle(title: l.homeCareTitle, subtitle: l.homeCareSubtitle),
          const SizedBox(height: 40),
          _Columns(
            layout: layout,
            children: [
              for (final (icon, title, body, fg, bg) in services)
                _FeatureCard(
                  icon: icon,
                  title: title,
                  body: body,
                  fg: fg,
                  bg: bg,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// For doctors

class _ForDoctors extends StatelessWidget {
  const _ForDoctors({super.key, required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final points = [
      (Icons.calendar_month_rounded, l.doctorsPoint1),
      (Icons.account_balance_wallet_rounded, l.doctorsPoint2),
      (Icons.devices_rounded, l.doctorsPoint3),
    ];

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.navForDoctors.toUpperCase(),
          style: text.labelMedium?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.doctorsBandTitle,
          style: (layout.mobile ? text.headlineSmall : text.headlineMedium)
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          l.doctorsBandBody,
          style: text.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => context.go('${Routes.register}?as=doctor'),
          icon: const Icon(Icons.arrow_forward_rounded),
          iconAlignment: IconAlignment.end,
          label: Text(l.joinAsDoctor),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size(0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, label) in points)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: text.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    return _Section(
      layout: layout,
      child: Container(
        padding: EdgeInsets.all(layout.mobile ? 28 : 56),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: layout.desktop
            ? Row(
                children: [
                  Expanded(flex: 3, child: copy),
                  const SizedBox(width: 56),
                  Expanded(flex: 2, child: list),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 28), list],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAQ

class _Faq extends StatelessWidget {
  const _Faq({super.key, required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (l.faq1Q, l.faq1A),
      (l.faq2Q, l.faq2A),
      (l.faq3Q, l.faq3A),
      (l.faq4Q, l.faq4A),
      (l.faq5Q, l.faq5A),
    ];
    return _Section(
      layout: layout,
      child: Column(
        children: [
          _SectionTitle(title: l.faqTitle),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                for (final (q, a) in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            18,
                          ),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          iconColor: AppColors.primary,
                          title: Text(
                            q,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          children: [
                            Text(
                              a,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.55,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Final call to action and footer

class _FinalCta extends StatelessWidget {
  const _FinalCta({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return _Section(
      layout: layout,
      bottom: layout.sectionGap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: layout.mobile ? 24 : 48,
          vertical: layout.mobile ? 36 : 56,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.onboardingGradient,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            const LogoMark(size: 56),
            const SizedBox(height: 20),
            Text(
              l.ctaTitle,
              textAlign: TextAlign.center,
              style: (layout.mobile ? text.headlineSmall : text.headlineMedium)
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(Routes.register),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l.ctaButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    const muted = Color(0xFF9FB3B0);

    Widget heading(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        s,
        style: text.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    Widget link(String s, VoidCallback onTap) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(s, style: text.bodyMedium?.copyWith(color: muted)),
      ),
    );

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(size: 36),
            const SizedBox(width: 10),
            Text(
              l.appName,
              style: text.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(l.footerTagline, style: text.bodyMedium?.copyWith(color: muted)),
        const SizedBox(height: 16),
        const LanguageSwitcher(),
      ],
    );
    final account = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(l.footerAccount),
        link(l.signIn, () => context.go(Routes.login)),
        link(l.createAccount, () => context.go(Routes.register)),
        link(l.joinAsDoctor, () => context.go('${Routes.register}?as=doctor')),
      ],
    );
    final contact = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(l.footerContact),
        SelectableText(
          'support@daktarinow.com',
          style: text.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emergency_rounded,
              size: 16,
              color: AppColors.accent,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l.footerEmergency,
                style: text.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFF10201F),
      padding: EdgeInsets.fromLTRB(layout.gutter, 48, layout.gutter, 32),
      child: SafeArea(
        top: false,
        child: ContentConstraint(
          maxWidth: 1160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (layout.mobile) ...[
                brand,
                const SizedBox(height: 32),
                account,
                const SizedBox(height: 24),
                contact,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: brand),
                    Expanded(child: account),
                    Expanded(child: contact),
                  ],
                ),
              const SizedBox(height: 32),
              const Divider(color: Color(0xFF243837)),
              const SizedBox(height: 16),
              Text(
                l.footerCopyright(DateTime.now().year),
                style: text.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and lifts its child in once, when the page first appears.
class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({required this.child});

  final Widget child;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
