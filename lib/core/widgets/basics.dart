import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../utils/format.dart';

/// White surface with a hairline border. The default container for content.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = Radii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? p.line),
    );
    return Material(
      color: color ?? p.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

/// Small status label.
class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    required this.tone,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Tone tone;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: tone.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: tone.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.padding,
    this.trailing,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.fromLTRB(Gap.page, Gap.xl, Gap.page - 8, Gap.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleLarge)),
          ?trailing,
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

/// Empty and zero states: say what's missing and how to fix it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Gap.xl,
        vertical: compact ? Gap.xl : 56,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 48 : 64,
            height: compact ? 48 : 64,
            decoration: BoxDecoration(
              color: p.greenTint,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Icon(icon, color: p.greenStrong, size: compact ? 24 : 30),
          ),
          const SizedBox(height: Gap.lg),
          Text(
            title,
            style: context.text.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: Gap.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message!,
                style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: Gap.lg),
            FilledButton.tonal(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: p.greenTint,
                foregroundColor: p.greenStrong,
                minimumSize: const Size(0, 44),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Thin progress bar, used for event prep, budgets and checklists.
class ThinProgress extends StatelessWidget {
  const ThinProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
    this.track,
  });

  final double value;
  final Color? color;
  final Color? track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          color: color ?? p.green,
          backgroundColor: track ?? p.surfaceAlt,
          minHeight: height,
        ),
      ),
    );
  }
}

/// Rounded icon tile used at the start of rows.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.tone, this.size = 40});

  final IconData icon;
  final Tone? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = tone ?? Tone.green(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: t.fg, size: size * 0.5),
    );
  }
}

/// Initials avatar. Colour is stable per person.
class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 36, this.ring});

  final String name;
  final double size;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final tones = [
      Tone.green(context),
      Tone.blue(context),
      Tone.violet(context),
      Tone.amber(context),
    ];
    final t =
        tones[name.codeUnits.fold<int>(0, (a, b) => a + b) % tones.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.bg,
        shape: BoxShape.circle,
        border: ring == null ? null : Border.all(color: ring!, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        Fmt.initials(name),
        style: TextStyle(
          fontFamily: Fonts.display,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
          color: t.fg,
          height: 1,
        ),
      ),
    );
  }
}

/// Overlapping avatars with a "+n" tail.
class AvatarStack extends StatelessWidget {
  const AvatarStack(this.names, {super.key, this.size = 26, this.max = 4});

  final List<String> names;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (names.isEmpty) return const SizedBox.shrink();
    final shown = names.take(max).toList();
    final extra = names.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    final step = size * 0.68;
    return SizedBox(
      height: size,
      width: step * (count - 1) + size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: Avatar(shown[i], size: size, ring: p.surface),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: context.text.labelSmall?.copyWith(
                    fontSize: size * 0.36,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Big number + small label.
class Stat extends StatelessWidget {
  const Stat({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.align = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final Color? color;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: context.text.headlineMedium?.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: context.text.bodySmall),
      ],
    );
  }
}

/// Key–value line in detail screens.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: p.inkMuted),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.text.titleSmall?.copyWith(
                    color: onTap != null ? p.greenStrong : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return onTap == null
        ? row
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Radii.sm),
            child: row,
          );
  }
}

class Toast {
  static void show(BuildContext context, String message, {bool error = false}) {
    final p = context.palette;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                error ? Icons.error_rounded : Icons.check_circle_rounded,
                color: error ? p.red : p.green,
                size: 20,
              ),
              const SizedBox(width: Gap.md),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final p = context.palette;
  final result = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          style: TextButton.styleFrom(foregroundColor: p.inkMuted),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? p.red : p.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 44),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Text input dialog (reasons, notes, payment refs).
Future<String?> promptDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String? message,
  bool required = true,
  bool destructive = false,
  int maxLines = 3,
}) {
  final controller = TextEditingController();
  final p = context.palette;
  return showDialog<String>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              Text(message),
              const SizedBox(height: Gap.lg),
            ],
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 1,
              maxLines: maxLines,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: label),
              onChanged: (_) => set(() {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            style: TextButton.styleFrom(foregroundColor: p.inkMuted),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: required && controller.text.trim().isEmpty
                ? null
                : () => Navigator.pop(c, controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? p.red : p.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
}
