import 'package:flutter/material.dart';

/// Design tokens ported 1:1 from the web app's `frontend/src/index.css`.
///
/// Every colour the UI paints comes from here so that light and dark mode stay
/// in sync with the web. Read it off the context with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color cream;
  final Color creamSoft;
  final Color shell;
  final Color surface;
  final Color ink;
  final Color inkSoft;

  /// Text drawn on top of `accent`. Stays dark in both themes, like the web.
  final Color inkFixed;

  final Color accent;
  final Color sage;
  final Color sageSoft;
  final Color coral;
  final Color coralSoft;
  final Color dustyBlue;
  final Color dustyBlueSoft;
  final Color slate;
  final Color slateSoft;

  /// The three stops of the `body` background gradient.
  final List<Color> backdropStops;

  /// Colour of the 56px background grid lines.
  final Color gridLine;

  /// The two accent glows bled into the background.
  final Color glowStrong;
  final Color glowSoft;

  /// `.glass-card` fill, border and drop shadow.
  final Color glassFill;
  final Color glassBorder;
  final Color glassShadow;

  const AppPalette({
    required this.cream,
    required this.creamSoft,
    required this.shell,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.inkFixed,
    required this.accent,
    required this.sage,
    required this.sageSoft,
    required this.coral,
    required this.coralSoft,
    required this.dustyBlue,
    required this.dustyBlueSoft,
    required this.slate,
    required this.slateSoft,
    required this.backdropStops,
    required this.gridLine,
    required this.glowStrong,
    required this.glowSoft,
    required this.glassFill,
    required this.glassBorder,
    required this.glassShadow,
  });

  static const light = AppPalette(
    cream: Color(0xFFF7F3EA),
    creamSoft: Color(0xFFEEE8D8),
    shell: Color(0xFFEDEAE1),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF1A1A1A),
    inkSoft: Color(0xFF4A473F),
    inkFixed: Color(0xFF1A1A1A),
    accent: Color(0xFFF5C842),
    sage: Color(0xFF8FA88A),
    sageSoft: Color(0xFFE7EDE5),
    coral: Color(0xFFD98C7B),
    coralSoft: Color(0xFFF6E6E2),
    dustyBlue: Color(0xFF7B96AD),
    dustyBlueSoft: Color(0xFFE6ECF1),
    slate: Color(0xFF565A6B),
    slateSoft: Color(0xFFE6E6EA),
    backdropStops: [Color(0xFFEFEEE9), Color(0xFFF6F1E3), Color(0xFFFAF1CF)],
    gridLine: Color(0x0B1A1A1A),
    glowStrong: Color(0x59F5C842),
    glowSoft: Color(0x40F5C842),
    glassFill: Color(0x8CFFFFFF),
    glassBorder: Color(0x99FFFFFF),
    glassShadow: Color(0x2E1A1A1A),
  );

  static const dark = AppPalette(
    cream: Color(0xFF121114),
    creamSoft: Color(0xFF2A2830),
    shell: Color(0xFF1C1B20),
    surface: Color(0xFF1E1D23),
    ink: Color(0xFFF2EFE6),
    inkSoft: Color(0xFFB3AE9F),
    inkFixed: Color(0xFF1A1A1A),
    accent: Color(0xFFF7D35C),
    sage: Color(0xFFA7C2A1),
    sageSoft: Color(0xFF223021),
    coral: Color(0xFFE3A190),
    coralSoft: Color(0xFF2F201C),
    dustyBlue: Color(0xFF9DB6C9),
    dustyBlueSoft: Color(0xFF1D2730),
    slate: Color(0xFFB0B3C4),
    slateSoft: Color(0xFF2A2B35),
    backdropStops: [Color(0xFF121114), Color(0xFF17151B), Color(0xFF1D1912)],
    gridLine: Color(0x09FFFFFF),
    glowStrong: Color(0x2EF7D35C),
    glowSoft: Color(0x24F7D35C),
    glassFill: Color(0x0FFFFFFF),
    glassBorder: Color(0x1AFFFFFF),
    glassShadow: Color(0x8C000000),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    // The two palettes are discrete design systems rather than points on a
    // ramp, so snapping at the midpoint reads better than blending them.
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
