import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';

/// Standard screen: large left-aligned title that collapses into the app bar,
/// then slivers. Keeps every screen's top the same shape.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.slivers,
    this.floatingActionButton,
    this.bottom,
    this.showBack,
    this.bottomBar,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> slivers;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final bool? showBack;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? Navigator.of(context).canPop();
    return Scaffold(
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: canPop,
            expandedHeight: subtitle == null ? 108 : 128,
            actions: [
              ...actions,
              const SizedBox(width: Gap.sm),
            ],
            bottom: bottom,
            flexibleSpace: _CollapsingTitle(
              title: title,
              subtitle: subtitle,
              hasLeading: canPop,
              hasBottom: bottom != null,
            ),
          ),
          ...slivers,
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _CollapsingTitle extends StatelessWidget {
  const _CollapsingTitle({
    required this.title,
    this.subtitle,
    required this.hasLeading,
    required this.hasBottom,
  });

  final String title;
  final String? subtitle;
  final bool hasLeading;
  final bool hasBottom;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
    final range = settings.maxExtent - settings.minExtent;
    final t = range <= 0
        ? 1.0
        : ((settings.currentExtent - settings.minExtent) / range).clamp(
            0.0,
            1.0,
          );
    final p = context.palette;
    final bottomH = hasBottom
        ? settings.minExtent -
              kToolbarHeight -
              MediaQuery.paddingOf(context).top
        : 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: p.background),
        // Collapsed title in the toolbar.
        Positioned(
          left: hasLeading ? 56 : Gap.page,
          right: 120,
          top: MediaQuery.paddingOf(context).top,
          height: kToolbarHeight,
          child: Opacity(
            opacity: (1 - t * 2.5).clamp(0, 1),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: context.text.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        // Large title.
        Positioned(
          left: Gap.page,
          right: Gap.page,
          bottom: 12 + bottomH,
          child: Opacity(
            opacity: ((t - 0.25) / 0.75).clamp(0, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.text.headlineLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (t < 0.05)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomH,
            child: Divider(height: 1, color: p.line),
          ),
      ],
    );
  }
}

/// Horizontal page padding for sliver content.
class PagePad extends StatelessWidget {
  const PagePad({
    super.key,
    required this.child,
    this.top = 0,
    this.bottom = 0,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.fromLTRB(Gap.page, top, Gap.page, bottom),
    sliver: SliverToBoxAdapter(child: child),
  );
}

/// Caps content width on tablets / desktop so lines stay readable.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.max = 760});

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}

/// Horizontal filter chips row.
class FilterBar<T> extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.counts,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final Map<T, int>? counts;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gap.page),
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
        itemBuilder: (context, i) {
          final v = values[i];
          final on = v == selected;
          final count = counts?[v];
          return Material(
            color: on ? p.ink : p.surface,
            shape: StadiumBorder(side: BorderSide(color: on ? p.ink : p.line)),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => onSelected(v),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: label(v)),
                        if (count != null)
                          TextSpan(
                            text: '  $count',
                            style: TextStyle(
                              color: on
                                  ? p.surface.withValues(alpha: 0.7)
                                  : p.inkFaint,
                            ),
                          ),
                      ],
                    ),
                    style: context.text.labelMedium?.copyWith(
                      color: on ? p.surface : p.ink,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
