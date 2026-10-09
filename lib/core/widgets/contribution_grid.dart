import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../utils/format.dart';

/// The chapter's signature visual: a commit-graph of contributions.
///
/// Columns are weeks (oldest on the left), rows are Monday → Sunday.
class ContributionGrid extends StatelessWidget {
  const ContributionGrid({
    super.key,
    required this.days,
    this.weeks = 16,
    this.colors,
    this.labelColor,
    this.showMonths = true,
    this.gap = 3,
  });

  final Map<DateTime, int> days;
  final int weeks;

  /// Five colours, empty → busiest. Defaults to the palette's heat scale.
  final List<Color>? colors;
  final Color? labelColor;
  final bool showMonths;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final scale = colors ?? context.palette.heat;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMonday = today.subtract(Duration(days: today.weekday - 1));
    final start = lastMonday.subtract(Duration(days: 7 * (weeks - 1)));
    final maxCount = days.values.fold<int>(1, (a, b) => b > a ? b : a);

    int level(int c) {
      if (c <= 0) return 0;
      final r = c / maxCount;
      if (r <= 0.25) return 1;
      if (r <= 0.5) return 2;
      if (r <= 0.75) return 3;
      return 4;
    }

    return LayoutBuilder(
      builder: (context, box) {
        final cell = ((box.maxWidth - gap * (weeks - 1)) / weeks).clamp(
          6.0,
          22.0,
        );
        final width = cell * weeks + gap * (weeks - 1);
        final labels = <Widget>[];
        if (showMonths) {
          int? lastMonth;
          for (var w = 0; w < weeks; w++) {
            final d = start.add(Duration(days: 7 * w));
            if (d.month != lastMonth && w < weeks - 1) {
              labels.add(
                Positioned(
                  left: w * (cell + gap),
                  child: Text(
                    Fmt.month(d),
                    style: context.text.labelSmall?.copyWith(
                      color: labelColor ?? context.palette.inkFaint,
                    ),
                  ),
                ),
              );
              lastMonth = d.month;
            }
          }
        }

        return Semantics(
          label:
              '${days.values.fold<int>(0, (a, b) => a + b)} contributions in the last $weeks weeks',
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMonths)
                  SizedBox(
                    height: 16,
                    width: width,
                    child: Stack(children: labels),
                  ),
                Row(
                  children: [
                    for (var w = 0; w < weeks; w++) ...[
                      if (w > 0) SizedBox(width: gap),
                      Column(
                        children: [
                          for (var d = 0; d < 7; d++) ...[
                            if (d > 0) SizedBox(height: gap),
                            Builder(
                              builder: (context) {
                                final date = start.add(
                                  Duration(days: 7 * w + d),
                                );
                                final future = date.isAfter(today);
                                final c = days[date] ?? 0;
                                return Container(
                                  width: cell,
                                  height: cell,
                                  decoration: BoxDecoration(
                                    color: future
                                        ? Colors.transparent
                                        : scale[level(c)],
                                    borderRadius: BorderRadius.circular(
                                      cell * 0.28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HeatLegend extends StatelessWidget {
  const HeatLegend({super.key, this.colors, this.labelColor});

  final List<Color>? colors;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final scale = colors ?? context.palette.heat;
    final style = context.text.labelSmall?.copyWith(
      color: labelColor ?? context.palette.inkFaint,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Less', style: style),
        const SizedBox(width: 6),
        for (final c in scale) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text('More', style: style),
      ],
    );
  }
}
