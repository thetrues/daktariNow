import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Initials avatar used until profile photos come from storage.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.online = false,
  });

  /// Builds initials from a full name, ignoring the "Dr." prefix.
  factory Avatar.fromName(String name, {double size = 48, bool online = false}) {
    final parts = name.replaceFirst('Dr. ', '').trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return Avatar(initials: initials, size: size, online: online);
  }

  final String initials;
  final double size;
  final bool online;

  static const _palette = [
    (AppColors.primarySoft, AppColors.primaryDark),
    (AppColors.accentSoft, Color(0xFFE0675C)),
    (AppColors.purpleSoft, Color(0xFF6E5BE0)),
    (AppColors.amberSoft, Color(0xFFD48A12)),
  ];

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _palette[initials.hashCode.abs() % _palette.length];
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(size * 0.32),
            ),
            child: Text(
              initials.toUpperCase(),
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.34,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
