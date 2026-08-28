import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// The web app's `.glass-card`: a translucent blurred panel with a bright
/// inner edge and a long, soft drop shadow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final borderRadius = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: palette.glassShadow,
            blurRadius: 40,
            spreadRadius: -22,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.glassFill,
              borderRadius: borderRadius,
              border: Border.all(color: palette.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A solid panel on `surface` — used where content needs to stay legible over
/// the backdrop (tables, sheets) rather than float above it.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.creamSoft),
        boxShadow: [
          BoxShadow(
            color: palette.glassShadow,
            blurRadius: 40,
            spreadRadius: -22,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
