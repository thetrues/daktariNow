import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.showName = true, this.size = 40});

  final bool showName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        Icons.monitor_heart_outlined,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
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
