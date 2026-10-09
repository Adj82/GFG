import 'package:flutter/material.dart';

/// SocietyOS colour tokens.
///
/// Built around GFG green (#2F8D46). Everything else is a tinted neutral so the
/// green stays the one thing that reads as "GeeksforGeeks" on every screen.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.line,
    required this.green,
    required this.greenStrong,
    required this.greenTint,
    required this.onGreen,
    required this.forest,
    required this.onForest,
    required this.amber,
    required this.amberTint,
    required this.red,
    required this.redTint,
    required this.blue,
    required this.blueTint,
    required this.violet,
    required this.violetTint,
    required this.heat,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color line;

  /// GFG brand green.
  final Color green;
  final Color greenStrong;
  final Color greenTint;
  final Color onGreen;

  /// Deep green used for the hero slabs (home, wallet, check-in).
  final Color forest;
  final Color onForest;

  final Color amber;
  final Color amberTint;
  final Color red;
  final Color redTint;
  final Color blue;
  final Color blueTint;
  final Color violet;
  final Color violetTint;

  /// Five-step scale for the contribution grid, empty → most active.
  final List<Color> heat;

  static const light = Palette(
    background: Color(0xFFF2F5F3),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE8EEEA),
    ink: Color(0xFF14211A),
    inkMuted: Color(0xFF56665D),
    inkFaint: Color(0xFF8A988F),
    line: Color(0xFFDCE4DF),
    green: Color(0xFF2F8D46),
    greenStrong: Color(0xFF1E6B33),
    greenTint: Color(0xFFDDF0E2),
    onGreen: Color(0xFFFFFFFF),
    forest: Color(0xFF0F2E1B),
    onForest: Color(0xFFE6F4EA),
    amber: Color(0xFFB7740B),
    amberTint: Color(0xFFFBEED5),
    red: Color(0xFFC23B33),
    redTint: Color(0xFFFBE3E1),
    blue: Color(0xFF2860C8),
    blueTint: Color(0xFFE1EAFB),
    violet: Color(0xFF6B4BC2),
    violetTint: Color(0xFFECE6FA),
    heat: [
      Color(0xFFE3EAE5),
      Color(0xFFB4DDBE),
      Color(0xFF6FBF84),
      Color(0xFF2F8D46),
      Color(0xFF175A2A),
    ],
  );

  static const dark = Palette(
    background: Color(0xFF0A120E),
    surface: Color(0xFF121C17),
    surfaceAlt: Color(0xFF1A2620),
    ink: Color(0xFFE6EFE9),
    inkMuted: Color(0xFF9DAFA4),
    inkFaint: Color(0xFF6C7D73),
    line: Color(0xFF25342C),
    green: Color(0xFF3FB65F),
    greenStrong: Color(0xFF5FD27E),
    greenTint: Color(0xFF173323),
    onGreen: Color(0xFF04140A),
    forest: Color(0xFF0E2618),
    onForest: Color(0xFFE6F4EA),
    amber: Color(0xFFE6A93C),
    amberTint: Color(0xFF33270F),
    red: Color(0xFFEF6B62),
    redTint: Color(0xFF3A1A18),
    blue: Color(0xFF6F9BEF),
    blueTint: Color(0xFF16223A),
    violet: Color(0xFFA48BEB),
    violetTint: Color(0xFF241C3A),
    heat: [
      Color(0xFF1B2721),
      Color(0xFF1D4A2C),
      Color(0xFF237A3D),
      Color(0xFF3FB65F),
      Color(0xFF8BE3A3),
    ],
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkFaint: l(inkFaint, other.inkFaint),
      line: l(line, other.line),
      green: l(green, other.green),
      greenStrong: l(greenStrong, other.greenStrong),
      greenTint: l(greenTint, other.greenTint),
      onGreen: l(onGreen, other.onGreen),
      forest: l(forest, other.forest),
      onForest: l(onForest, other.onForest),
      amber: l(amber, other.amber),
      amberTint: l(amberTint, other.amberTint),
      red: l(red, other.red),
      redTint: l(redTint, other.redTint),
      blue: l(blue, other.blue),
      blueTint: l(blueTint, other.blueTint),
      violet: l(violet, other.violet),
      violetTint: l(violetTint, other.violetTint),
      heat: [for (var i = 0; i < heat.length; i++) l(heat[i], other.heat[i])],
    );
  }
}

extension PaletteX on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// A foreground/background pair used by pills, icons and tags.
class Tone {
  const Tone(this.fg, this.bg);
  final Color fg;
  final Color bg;

  static Tone green(BuildContext c) =>
      Tone(c.palette.greenStrong, c.palette.greenTint);
  static Tone amber(BuildContext c) =>
      Tone(c.palette.amber, c.palette.amberTint);
  static Tone red(BuildContext c) => Tone(c.palette.red, c.palette.redTint);
  static Tone blue(BuildContext c) => Tone(c.palette.blue, c.palette.blueTint);
  static Tone violet(BuildContext c) =>
      Tone(c.palette.violet, c.palette.violetTint);
  static Tone neutral(BuildContext c) =>
      Tone(c.palette.inkMuted, c.palette.surfaceAlt);
}
