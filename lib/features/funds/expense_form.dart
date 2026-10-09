import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/icons.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/finance_actions.dart';
import '../../domain/expense_rules.dart';

Future<void> showExpenseForm(BuildContext context, {String? eventId}) =>
    showFormSheet<void>(context, builder: (_) => ExpenseForm(eventId: eventId));

class ExpenseForm extends ConsumerStatefulWidget {
  const ExpenseForm({super.key, this.eventId});

  final String? eventId;

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;
  late String? _eventId = widget.eventId;
  PlatformFile? _receipt;
  int _receiptSize = 0;
  String? _receiptPath;
  String? _receiptError;
  var _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'heic'],
    );
    if (f == null) return;
    final size = await f.xFile.length();
    if (!mounted) return;
    setState(() {
      _receipt = f;
      _receiptSize = size;
      _receiptPath = f.path; // null on web: bytes only
      _receiptError = null;
    });
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    if (_receipt == null) {
      setState(
        () =>
            _receiptError = 'Attach the bill or receipt. Photos and PDFs work.',
      );
    }
    if (!valid || _receipt == null) return;
    setState(() => _busy = true);
    await ref
        .read(financeActionsProvider)
        .submit(
          title: _title.text,
          amount: parseAmount(_amount.text),
          category: _category,
          description: _desc.text,
          eventId: _eventId,
          receiptName: _receipt!.name,
          receiptRef: _receiptPath,
        );
    if (!mounted) return;
    Navigator.pop(context);
    Toast.show(context, 'Expense submitted for review');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = ref.watch(accessProvider)!;
    final now = DateTime.now();
    final events =
        ref
            .watch(eventsProvider)
            .where(
              (e) =>
                  !e.cancelled &&
                  e.startsAt.isAfter(now.subtract(const Duration(days: 45))),
            )
            .toList()
          ..sort((x, y) => y.startsAt.compareTo(x.startsAt));
    final entry = ExpenseRules.entryStage(
      submitterRole: a.role,
      domainId: a.me.domainId,
    );
    final route = ExpenseStage.chain
        .where(
          (s) =>
              ExpenseStage.chain.indexOf(s) >=
              ExpenseStage.chain.indexOf(entry),
        )
        .map((s) => s.label)
        .join(' → ');

    return FormSheet(
      formKey: _form,
      title: 'Submit an expense',
      subtitle: 'It goes to: $route',
      submitLabel: 'Submit for review',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'What was it for?',
            hintText: 'Snacks for Flutter workshop',
          ),
          validator: (v) => requiredText(v, 'Say what the money was spent on.'),
        ),
        TextFormField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
          validator: amountValidator,
        ),
        FieldLabel(
          'Category',
          child: ChoiceChips<ExpenseCategory>(
            values: ExpenseCategory.values,
            selected: _category,
            label: (c) => c.label,
            icon: AppIcons.expense,
            onSelected: (v) => setState(() => _category = v),
          ),
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
                  child: Text(
                    '${e.title} · ${Fmt.dateShort(e.startsAt)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _eventId = v),
          ),
        FieldLabel(
          'Receipt',
          hint: _receiptError,
          child: Material(
            color: _receipt != null ? p.greenTint : p.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              side: BorderSide(
                color: _receiptError != null
                    ? p.red
                    : (_receipt != null ? p.green : p.line),
                width: _receipt == null ? 1 : 1.4,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.md),
              onTap: _pick,
              child: Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Row(
                  children: [
                    Icon(
                      _receipt != null
                          ? Icons.task_rounded
                          : Icons.upload_file_rounded,
                      color: _receipt != null ? p.greenStrong : p.inkMuted,
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _receipt?.name ?? 'Attach a photo or PDF',
                            style: context.text.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_receipt != null)
                            Text(
                              Fmt.fileSize(_receiptSize),
                              style: context.text.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (_receipt != null)
                      Text(
                        'Change',
                        style: context.text.labelMedium?.copyWith(
                          color: p.greenStrong,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        TextFormField(
          controller: _desc,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Notes for the reviewer (optional)',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

Future<void> showIncomeForm(BuildContext context) =>
    showFormSheet<void>(context, builder: (_) => const IncomeForm());

class IncomeForm extends ConsumerStatefulWidget {
  const IncomeForm({super.key});

  @override
  ConsumerState<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends ConsumerState<IncomeForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _ref = TextEditingController();
  final _note = TextEditingController();
  IncomeSource _source = IncomeSource.sponsorship;
  DateTime _date = DateTime.now();
  String? _eventId;
  var _busy = false;

  @override
  void dispose() {
    for (final c in [_title, _amount, _ref, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await ref
        .read(financeActionsProvider)
        .logIncome(
          title: _title.text,
          amount: parseAmount(_amount.text),
          source: _source,
          receivedAt: _date,
          eventId: _eventId,
          reference: _ref.text,
          note: _note.text,
        );
    if (!mounted) return;
    Navigator.pop(context);
    Toast.show(context, 'Income logged');
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider).where((e) => !e.cancelled).toList()
      ..sort((x, y) => y.startsAt.compareTo(x.startsAt));
    return FormSheet(
      formKey: _form,
      title: 'Log income',
      subtitle: 'Money coming into the chapter wallet.',
      submitLabel: 'Log income',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'From whom, and for what?',
          ),
          validator: (v) => requiredText(v, 'Say where the money came from.'),
        ),
        TextFormField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
          validator: amountValidator,
        ),
        FieldLabel(
          'Source',
          child: ChoiceChips<IncomeSource>(
            values: IncomeSource.values,
            selected: _source,
            label: (s) => s.label,
            icon: AppIcons.income,
            onSelected: (v) => setState(() => _source = v),
          ),
        ),
        DateTimeField(
          label: 'Received on',
          value: _date,
          withTime: false,
          onChanged: (v) => setState(() => _date = v ?? _date),
        ),
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
              child: Text('General chapter income'),
            ),
            for (final e in events)
              DropdownMenuItem(
                value: e.id,
                child: Text(e.title, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() => _eventId = v),
        ),
        TextFormField(
          controller: _ref,
          decoration: const InputDecoration(
            labelText: 'Reference (optional)',
            hintText: 'UTR, cheque or invoice number',
          ),
        ),
        TextFormField(
          controller: _note,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Note (optional)',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
