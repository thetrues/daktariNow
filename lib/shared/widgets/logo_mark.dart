import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The DaktariNow mark: a consultation bubble with a medical cross on a teal
/// tile. Drawn in code so it stays sharp at any size; the same geometry is in
/// medic_app/tool/brand/logo.svg, which also generates the app icons.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: const _LogoPainter(),
      );
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Designed on a 100 x 100 grid.
    canvas.scale(size.width / 100);
    const tile = Rect.fromLTWH(0, 0, 100, 100);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tile, const Radius.circular(24)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ).createShader(tile),
    );

    final white = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromLTRBR(20, 22, 80, 72, const Radius.circular(14)),
      white,
    );
    canvas.drawPath(
      Path()
        ..moveTo(30, 70)
        ..lineTo(26, 84)
        ..lineTo(46, 70)
        ..close(),
      white,
    );

    final cross = Paint()..color = AppColors.primary;
    canvas.drawRect(const Rect.fromLTRB(45, 32, 55, 62), cross);
    canvas.drawRect(const Rect.fromLTRB(35, 42, 65, 52), cross);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
