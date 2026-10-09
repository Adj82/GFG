import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/icons.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';

/// Create or edit a task. Pass [task] to edit, [eventId] to pre-attach to an event.
Future<void> showTaskForm(
  BuildContext context, {
  SocietyTask? task,
  String? eventId,
  String? domainId,
}) {
  return showFormSheet<void>(
    context,
    builder: (_) => TaskForm(task: task, eventId: eventId, domainId: domainId),
  );
}

class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({super.key, this.task, this.eventId, this.domainId});

  final SocietyTask? task;
  final String? eventId;
  final String? domainId;

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.task?.title);
  late final _desc = TextEditingController(text: widget.task?.description);
  late String? _domainId = widget.task != null
      ? widget.task!.domainId
      : widget.domainId;
  late String? _eventId = widget.task?.eventId ?? widget.eventId;
  late List<String> _assignees = [...?widget.task?.assigneeIds];
  late DateTime? _due = widget.task?.due;
  late TaskPriority _priority = widget.task?.priority ?? TaskPriority.medium;
  final _newItem = TextEditingController();
  final List<String> _checklist = [];
  var _busy = false;
  String? _domainError;

  bool get _editing => widget.task != null;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _newItem.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final a = ref.read(accessProvider)!;
    if (_domainId == null && !a.isSocietyWide) {
      setState(() => _domainError = 'Choose a domain you manage.');
      return;
    }
    setState(() => _busy = true);
    final actions = ref.read(taskActionsProvider);
    if (_editing) {
      await actions.update(
        widget.task!,
        widget.task!.copyWith(
          title: _title.text.trim(),
          description: _desc.text.trim(),
          domainId: _domainId,
          eventId: _eventId,
          assigneeIds: _assignees,
          due: _due,
          priority: _priority,
        ),
      );
    } else {
      await actions.create(
        title: _title.text,
        description: _desc.text,
        domainId: _domainId,
        eventId: _eventId,
        assigneeIds: _assignees,
        due: _due,
        priority: _priority,
        checklist: _checklist,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    Toast.show(context, _editing ? 'Task updated' : 'Task created');
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(accessProvider)!;
    final domains = ref.watch(domainMapProvider);
    final reach = a.domainsInReach;
    final members = ref.watch(activeMembersProvider);
    final events = ref.watch(upcomingEventsProvider);
    // People you can assign: anyone in the chosen domain, or anyone if society-wide.
    final candidates = _domainId == null
        ? members
        : members
              .where(
                (m) =>
                    m.domainId == _domainId ||
                    (ref.read(roleMapProvider)[m.roleId]?.scope ==
                        RoleScope.society),
              )
              .toList();
    final p = context.palette;

    return FormSheet(
      formKey: _form,
      title: _editing ? 'Edit task' : 'New task',
      submitLabel: _editing ? 'Save changes' : 'Create task',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _title,
          autofocus: !_editing,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'What needs doing?'),
          validator: (v) => requiredText(v, 'Give the task a title.'),
        ),
        TextFormField(
          controller: _desc,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Details (optional)',
            alignLabelWithHint: true,
          ),
        ),
        FieldLabel(
          'Priority',
          child: ChoiceChips<TaskPriority>(
            values: TaskPriority.values,
            selected: _priority,
            label: (v) => v.label,
            icon: AppIcons.priority,
            onSelected: (v) => setState(() => _priority = v),
          ),
        ),
        DateTimeField(
          label: 'Due date',
          value: _due,
          withTime: false,
          icon: Icons.flag_outlined,
          clearable: true,
          onChanged: (v) => setState(() => _due = v),
        ),
        FieldLabel(
          'Domain',
          hint:
              _domainError ??
              (a.isSocietyWide ? 'Leave empty for a society-wide task.' : null),
          child: Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              if (a.isSocietyWide)
                ChoiceChip(
                  label: const Text('Whole society'),
                  selected: _domainId == null,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    _domainId = null;
                    _assignees = [];
                  }),
                ),
              for (final d in reach)
                ChoiceChip(
                  avatar: Icon(AppIcons.domain(d.icon), size: 16),
                  label: Text(d.name),
                  selected: _domainId == d.id,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    _domainId = d.id;
                    _domainError = null;
                    _assignees = _assignees
                        .where((id) => candidates.any((m) => m.id == id))
                        .toList();
                  }),
                ),
            ],
          ),
        ),
        MemberPickerField(
          label: 'Assign to',
          members: candidates,
          selectedIds: _assignees,
          onChanged: (v) => setState(() => _assignees = v),
          subtitle: (m) =>
              domains[m.domainId]?.name ??
              ref.read(roleMapProvider)[m.roleId]?.name ??
              '',
        ),
        if (events.isNotEmpty)
          DropdownButtonFormField<String?>(
            initialValue: _eventId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Event (optional)',
              prefixIcon: Icon(Icons.event_rounded),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Not tied to an event'),
              ),
              for (final e in events)
                DropdownMenuItem(
                  value: e.id,
                  child: Text(e.title, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _eventId = v),
          ),
        if (!_editing)
          FieldLabel(
            'Checklist (optional)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in _checklist)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_box_outline_blank_rounded,
                          size: 20,
                          color: p.inkFaint,
                        ),
                        const SizedBox(width: Gap.sm),
                        Expanded(child: Text(c)),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () => setState(() => _checklist.remove(c)),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _newItem,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Add a step',
                    suffixIcon: IconButton(
                      tooltip: 'Add step',
                      icon: const Icon(Icons.add_rounded),
                      onPressed: _addItem,
                    ),
                  ),
                  onSubmitted: (_) => _addItem(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addItem() {
    final t = _newItem.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _checklist.add(t);
      _newItem.clear();
    });
  }
}
