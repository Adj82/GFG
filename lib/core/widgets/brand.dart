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

/// Contribution-grid banner whose lit squares spell "GFG". The rest of the
/// grid is faint filler so the letters read clearly. Deterministic, so it
/// doesn't flicker on rebuild.
class GridTexture extends StatelessWidget {
  const GridTexture({
    super.key,
    this.seed = 7,
    this.columns = 21,
    this.cell = 12,
    this.word = 'GFG',
  });

  static const rows = 6;

  /// 5 wide x 6 tall glyphs. '#' is a lit square.
  static const _glyphs = <String, List<String>>{
    'G': ['.###.', '#...#', '#....', '#.###', '#...#', '.###.'],
    'F': ['#####', '#....', '####.', '#....', '#....', '#....'],
  };

  final int seed;
  final int columns;
  final double cell;
  final String word;

  /// Lit cells as "x,y" keys, with the word centred horizontally.
  Set<String> _lit() {
    final width = word.length * 5 + (word.length - 1);
    var x0 = ((columns - width) / 2).floor();
    final lit = <String>{};
    for (final ch in word.split('')) {
      final g = _glyphs[ch];
      if (g == null) continue;
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < 5; x++) {
          if (g[y][x] == '#') lit.add('${x0 + x},$y');
        }
      }
      x0 += 6;
    }
    return lit;
  }

  @override
  Widget build(BuildContext context) {
    final r = Random(seed);
    final p = context.palette;
    final lit = _lit();
    final faint = [
      p.onForest.withValues(alpha: 0.05),
      p.onForest.withValues(alpha: 0.05),
      p.green.withValues(alpha: 0.16),
    ];
    return Semantics(
      label: word,
      child: ExcludeSemantics(
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
                        margin: EdgeInsets.only(
                          right: x == columns - 1 ? 0 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: lit.contains('$x,$y')
                              ? p.green
                              : faint[r.nextInt(faint.length)],
                          borderRadius: BorderRadius.circular(cell * 0.28),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
