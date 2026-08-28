import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// The web app's `body` background: a 160° cream gradient, two soft accent
/// glows bled into the corners, and a 56px grid overlay.
class AppBackdrop extends StatelessWidget {
  final Widget child;
  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // CSS `160deg`: down and slightly to the right.
          begin: const Alignment(-0.34, -0.94),
          end: const Alignment(0.34, 0.94),
          colors: palette.backdropStops,
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _BackdropPainter(palette),
        child: child,
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final AppPalette palette;
  const _BackdropPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    final glowRadius = diagonal * 0.32;

    void glow(Offset center, Color color) {
      final rect = Rect.fromCircle(center: center, radius: glowRadius);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    glow(Offset(size.width * 0.06, size.height * 0.08), palette.glowStrong);
    glow(Offset(size.width * 0.96, size.height * 0.70), palette.glowSoft);

    // 56px grid, drawn last so it sits over the glows like the CSS stack.
    final line = Paint()
      ..color = palette.gridLine
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y <= size.height; y += 56) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) => oldDelegate.palette != palette;
}
