import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/icons.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';
import '../../domain/event_templates.dart';

Future<SocietyEvent?> showEventForm(
  BuildContext context, {
  SocietyEvent? event,
}) {
  return showFormSheet<SocietyEvent>(
    context,
    builder: (_) => EventForm(event: event),
  );
}

class EventForm extends ConsumerStatefulWidget {
  const EventForm({super.key, this.event});

  final SocietyEvent? event;

  @override
  ConsumerState<EventForm> createState() => _EventFormState();
}

class _EventFormState extends ConsumerState<EventForm> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.event?.title);
  late final _venue = TextEditingController(text: widget.event?.venue);
  late final _desc = TextEditingController(text: widget.event?.description);
  late final _budget = TextEditingController(
    text: widget.event == null || widget.event!.budget == 0
        ? ''
        : widget.event!.budget.toStringAsFixed(0),
  );
  late final _capacity = TextEditingController(
    text: widget.event?.capacity?.toString() ?? '',
  );
  late EventType _type = widget.event?.type ?? EventType.workshop;
  late DateTime? _start = widget.event?.startsAt;
  late DateTime? _end = widget.event?.endsAt;
  late String? _domainId = widget.event?.domainId;
  late List<String> _organizers = [...?widget.event?.organizerIds];
  var _prep = true;
  var _busy = false;
  String? _error;

  bool get _editing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final a = ref.read(accessProvider)!;
    if (!_editing && !a.isSocietyWide) _domainId = a.me.domainId;
  }

  @override
  void dispose() {
    for (final c in [_title, _venue, _desc, _budget, _capacity]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_start == null) {
      return setState(() => _error = 'Choose when the event starts.');
    }
    final end = _end ?? _start!.add(const Duration(hours: 2));
    if (!end.isAfter(_start!)) {
      return setState(() => _error = 'The end time must be after the start.');
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final actions = ref.read(eventActionsProvider);
    final budget =
        double.tryParse(_budget.text.replaceAll(',', '').trim()) ?? 0;
    final capacity = int.tryParse(_capacity.text.trim());
    SocietyEvent result;
    if (_editing) {
      result = widget.event!.copyWith(
        title: _title.text.trim(),
        type: _type,
        description: _desc.text.trim(),
        startsAt: _start,
        endsAt: end,
        venue: _venue.text.trim(),
        domainId: _domainId,
        organizerIds: _organizers,
        budget: budget,
        capacity: capacity,
      );
      await actions.update(result);
    } else {
      result = await actions.create(
        title: _title.text,
        type: _type,
        startsAt: _start!,
        endsAt: end,
        venue: _venue.text,
        description: _desc.text,
        domainId: _domainId,
        organizerIds: _organizers,
        budget: budget,
        capacity: capacity,
        addPrepTasks: _prep,
      );
    }
    if (!mounted) return;
    Navigator.pop(context, result);
    Toast.show(context, _editing ? 'Event updated' : 'Event created');
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(accessProvider)!;
    final members = ref.watch(activeMembersProvider);
    final domains = ref.watch(domainMapProvider);
    final reach = a.domainsInReach;
    final prepCount = EventTemplates.forType(_type).length;

    return FormSheet(
      formKey: _form,
      title: _editing ? 'Edit event' : 'New event',
      submitLabel: _editing ? 'Save changes' : 'Create event',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _title,
          autofocus: !_editing,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Event name'),
          validator: (v) => requiredText(v, 'Give the event a name.'),
        ),
        FieldLabel(
          'Type',
          child: ChoiceChips<EventType>(
            values: EventType.values,
            selected: _type,
            label: (t) => t.label,
            icon: AppIcons.event,
            onSelected: (v) => setState(() => _type = v),
          ),
        ),
        DateTimeField(
          label: 'Starts',
          value: _start,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          onChanged: (v) => setState(() {
            _start = v;
            if (v != null && (_end == null || !_end!.isAfter(v))) {
              _end = v.add(const Duration(hours: 2));
            }
          }),
        ),
        DateTimeField(
          label: 'Ends',
          value: _end,
          icon: Icons.event_busy_rounded,
          firstDate: _start,
          onChanged: (v) => setState(() => _end = v),
        ),
        TextFormField(
          controller: _venue,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Venue',
            prefixIcon: Icon(Icons.place_outlined),
          ),
          validator: (v) => requiredText(
            v,
            'Where is it happening? Use “Online” if virtual.',
          ),
        ),
        FieldLabel(
          'Hosted by',
          child: Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              if (a.isSocietyWide)
                ChoiceChip(
                  label: const Text('Whole chapter'),
                  selected: _domainId == null,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _domainId = null),
                ),
              for (final d in reach)
                ChoiceChip(
                  avatar: Icon(AppIcons.domain(d.icon), size: 16),
                  label: Text(d.name),
                  selected: _domainId == d.id,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _domainId = d.id),
                ),
            ],
          ),
        ),
        MemberPickerField(
          label: 'Organisers',
          members: members,
          selectedIds: _organizers,
          onChanged: (v) => setState(() => _organizers = v),
          subtitle: (m) => domains[m.domainId]?.name ?? '',
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _budget,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  prefixText: '₹ ',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? null : amountValidator(v),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: TextFormField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Seats',
                  hintText: 'Unlimited',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  return (n == null || n < 1) ? 'Use a whole number.' : null;
                },
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _desc,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'What’s it about?',
            alignLabelWithHint: true,
          ),
        ),
        if (!_editing)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _prep,
            onChanged: (v) => setState(() => _prep = v),
            title: const Text('Add a prep checklist'),
            subtitle: Text(
              'Creates $prepCount tasks for a ${_type.label.toLowerCase()} with deadlines counted back from the date.',
            ),
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
