import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'logo_mark.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.showName = true, this.size = 40});

  final bool showName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mark = LogoMark(size: size);
    if (!showName) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(
            text: 'Daktari',
            children: const [
              TextSpan(
                text: 'Now',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          semanticsLabel: 'DaktariNow',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}
