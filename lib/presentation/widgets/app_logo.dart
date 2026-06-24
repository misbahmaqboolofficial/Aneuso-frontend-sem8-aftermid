import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Circular recycle emblem for branding across the app (no image asset).
class AppRecycleEmblem extends StatelessWidget {
  const AppRecycleEmblem({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.45),
            blurRadius: 32,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.78,
          height: size * 0.78,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryMid, AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: Icon(
            Icons.recycling_rounded,
            size: size * 0.44,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
