import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';

/// SocietyOS mark: a green tile with a code-bracket glyph.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? p.onForest : p.green,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        '</>',
        style: TextStyle(
          fontFamily: Fonts.display,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          letterSpacing: -1,
          color: onDark ? p.forest : p.onGreen,
          height: 1,
        ),
      ),
    );
  }
}

/// Decorative contribution-grid texture for hero slabs. Deterministic so it
/// doesn't flicker on rebuild.
class GridTexture extends StatelessWidget {
  const GridTexture({
    super.key,
    this.seed = 7,
    this.columns = 22,
    this.rows = 6,
    this.cell = 12,
  });

  final int seed;
  final int columns;
  final int rows;
  final double cell;

  @override
  Widget build(BuildContext context) {
    final r = Random(seed);
    final p = context.palette;
    final levels = [
      p.onForest.withValues(alpha: 0.05),
      p.green.withValues(alpha: 0.35),
      p.green.withValues(alpha: 0.6),
      p.green,
      p.greenStrong,
    ];
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var y = 0; y < rows; y++)
            Padding(
              padding: EdgeInsets.only(bottom: y == rows - 1 ? 0 : 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var x = 0; x < columns; x++)
                    Container(
                      width: cell,
                      height: cell,
                      margin: EdgeInsets.only(right: x == columns - 1 ? 0 : 3),
                      decoration: BoxDecoration(
                        color:
                            levels[(r.nextDouble() * r.nextDouble() * 5)
                                .floor()
                                .clamp(0, 4)],
                        borderRadius: BorderRadius.circular(cell * 0.28),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
