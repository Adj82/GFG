import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../utils/format.dart';
import 'basics.dart';

/// Opens a full-height form sheet that respects the keyboard.
Future<T?> showFormSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(c).height * 0.92,
        ),
        child: builder(c),
      ),
    ),
  );
}

/// Title + scrolling fields + a pinned primary button.
class FormSheet extends StatelessWidget {
  const FormSheet({
    super.key,
    required this.title,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    this.busy = false,
    this.subtitle,
    this.formKey,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool busy;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Gap.page,
                Gap.sm,
                Gap.page,
                Gap.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: Gap.lg),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              Gap.page,
              Gap.md,
              Gap.page,
              Gap.lg,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: p.line)),
            ),
            child: FilledButton(
              onPressed: busy ? null : onSubmit,
              child: busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: p.inkMuted,
                      ),
                    )
                  : Text(submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label above a group of controls inside a form.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, required this.child, this.hint});

  final String text;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: context.text.labelMedium?.copyWith(
            color: context.palette.inkMuted,
          ),
        ),
        const SizedBox(height: Gap.sm),
        child,
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: context.text.bodySmall),
        ],
      ],
    );
  }
}

/// Single-select chips.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.icon,
  });

  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final IconData Function(T)? icon;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(label(v)),
            avatar: icon == null ? null : Icon(icon!(v), size: 16),
            selected: v == selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(v),
          ),
      ],
    );
  }
}

/// Tappable field that opens date and time pickers.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.withTime = true,
    this.firstDate,
    this.icon = Icons.event_rounded,
    this.clearable = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool withTime;
  final DateTime? firstDate;
  final IconData icon;
  final bool clearable;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final base = value ?? DateTime(now.year, now.month, now.day, 17);
    final d = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (d == null || !context.mounted) return;
    if (!withTime) {
      onChanged(DateTime(d.year, d.month, d.day, 23, 59));
      return;
    }
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (t == null) return;
    onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(Radii.md),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: clearable && value != null
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onChanged(null),
                  tooltip: 'Clear',
                )
              : null,
        ),
        isEmpty: value == null,
        child: value == null
            ? const SizedBox(height: 20)
            : Text(
                withTime ? Fmt.dateTime(value!) : Fmt.weekdayDate(value!),
                style: context.text.bodyLarge?.copyWith(color: p.ink),
              ),
      ),
    );
  }
}

/// Picks people from a list, with search.
class MemberPickerField extends StatelessWidget {
  const MemberPickerField({
    super.key,
    required this.label,
    required this.members,
    required this.selectedIds,
    required this.onChanged,
    this.multiple = true,
    this.subtitle,
  });

  final String label;
  final List<Member> members;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;
  final bool multiple;
  final String Function(Member)? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final byId = {for (final m in members) m.id: m};
    final chosen = selectedIds
        .map((id) => byId[id])
        .whereType<Member>()
        .toList();
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.md),
      onTap: () async {
        final result = await showModalBottomSheet<List<String>>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (c) => SizedBox(
            height: MediaQuery.sizeOf(c).height * 0.8,
            child: _MemberPicker(
              title: label,
              members: members,
              initial: selectedIds,
              multiple: multiple,
              subtitle: subtitle,
            ),
          ),
        );
        if (result != null) onChanged(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.person_add_alt_rounded),
        ),
        isEmpty: chosen.isEmpty,
        child: chosen.isEmpty
            ? const SizedBox(height: 20)
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final m in chosen)
                    Container(
                      padding: const EdgeInsets.fromLTRB(3, 3, 10, 3),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Avatar(m.name, size: 22),
                          const SizedBox(width: 6),
                          Text(m.name, style: context.text.labelMedium),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _MemberPicker extends StatefulWidget {
  const _MemberPicker({
    required this.title,
    required this.members,
    required this.initial,
    required this.multiple,
    this.subtitle,
  });

  final String title;
  final List<Member> members;
  final List<String> initial;
  final bool multiple;
  final String Function(Member)? subtitle;

  @override
  State<_MemberPicker> createState() => _MemberPickerState();
}

class _MemberPickerState extends State<_MemberPicker> {
  late final _selected = [...widget.initial];
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = widget.members
        .where(
          (m) =>
              q.isEmpty ||
              m.name.toLowerCase().contains(q) ||
              m.email.contains(q),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.sm, Gap.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.title, style: context.text.headlineSmall),
              ),
              if (widget.multiple)
                TextButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: Text('Done (${_selected.length})'),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.page),
          child: TextField(
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'Search by name or roll number',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No one matches that search',
                  compact: true,
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final m = list[i];
                    final on = _selected.contains(m.id);
                    return ListTile(
                      leading: Avatar(m.name),
                      title: Text(m.name),
                      subtitle: widget.subtitle == null
                          ? null
                          : Text(widget.subtitle!(m)),
                      trailing: widget.multiple
                          ? Checkbox(value: on, onChanged: (_) => _toggle(m.id))
                          : (on
                                ? Icon(
                                    Icons.check_rounded,
                                    color: context.palette.green,
                                  )
                                : null),
                      onTap: () {
                        if (widget.multiple) {
                          _toggle(m.id);
                        } else {
                          Navigator.pop(context, [m.id]);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _toggle(String id) => setState(
    () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id),
  );
}

String? requiredText(String? v, [String message = 'This field is required.']) =>
    (v == null || v.trim().isEmpty) ? message : null;

String? amountValidator(String? v) {
  final n = double.tryParse((v ?? '').replaceAll(',', '').trim());
  if (n == null) return 'Enter an amount in rupees.';
  if (n <= 0) return 'Amount must be more than zero.';
  if (n > 1000000) return 'That’s over ₹10 lakh. Split it or check the number.';
  return null;
}

double parseAmount(String v) => double.parse(v.replaceAll(',', '').trim());
