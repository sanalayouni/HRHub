import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// The web's `FolderCard`: a glass panel with a small tab poking out of the
/// top-left edge, like a file folder.
class FolderCard extends StatelessWidget {
  final Widget child;
  const FolderCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget glass({required Widget child, required BorderRadius radius}) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.glassFill,
              borderRadius: radius,
              border: Border.all(color: palette.glassBorder),
            ),
            child: child,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: -26,
            child: glass(
              radius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: const SizedBox(width: 140, height: 40),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: palette.glassShadow,
                  blurRadius: 40,
                  spreadRadius: -22,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: glass(radius: BorderRadius.circular(20), child: child),
          ),
        ],
      ),
    );
  }
}
