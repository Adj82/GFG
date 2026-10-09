import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/people_actions.dart';
import '../../domain/default_roles.dart';
import '../../domain/expense_rules.dart';

class HandoverScreen extends ConsumerStatefulWidget {
  const HandoverScreen({super.key});

  @override
  ConsumerState<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends ConsumerState<HandoverScreen> {
  late final _term = TextEditingController(
    text: _nextTerm(ref.read(organizationProvider)?.currentTerm ?? ''),
  );
  final Map<String, String?> _holders = {};
  final Set<String> _alumni = {};
  var _seeded = false;
  var _busy = false;

  static String _nextTerm(String t) {
    final m = RegExp(r'(\d{4})\D+(\d{2,4})').firstMatch(t);
    if (m == null) return '';
    final a = int.parse(m.group(1)!) + 1;
    return '$a–${((a + 1) % 100).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _term.dispose();
    super.dispose();
  }

  List<Office> _offices(List<Domain> domains) => [
    const Office(roleId: DefaultRoles.president, holderId: null),
    const Office(roleId: DefaultRoles.vicePresident, holderId: null),
    const Office(roleId: DefaultRoles.treasurer, holderId: null),
    const Office(
      roleId: DefaultRoles.technicalHead,
      dept: Department.technical,
      holderId: null,
    ),
    const Office(
      roleId: DefaultRoles.nonTechnicalHead,
      dept: Department.nonTechnical,
      holderId: null,
    ),
    for (final d in domains)
      Office(
        roleId: DefaultRoles.domainLead,
        domainId: d.id,
        dept: d.department,
        holderId: null,
      ),
  ];

  String _label(
    Office o,
    Map<String, Role> roles,
    Map<String, Domain> domains,
  ) => o.domainId == null
      ? (roles[o.roleId]?.name ?? o.roleId)
      : '${domains[o.domainId]?.name} lead';

  Future<void> _confirm(List<Office> offices) async {
    final seated = offices
        .map(
          (o) => Office(
            roleId: o.roleId,
            domainId: o.domainId,
            dept: o.dept,
            holderId: _holders[o.key],
          ),
        )
        .where((o) => o.holderId != null)
        .toList();
    if (_term.text.trim().isEmpty) {
      return Toast.show(context, 'Name the new term', error: true);
    }
    if (!seated.any((o) => o.roleId == DefaultRoles.president)) {
      return Toast.show(context, 'A President is required', error: true);
    }
    final ok = await confirmDialog(
      context,
      title: 'Start the ${_term.text.trim()} term?',
      message:
          'Offices are reassigned, everyone’s history is saved, and outgoing people marked as alumni lose sign-in access. This can’t be undone.',
      confirmLabel: 'Start new term',
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    await ref
        .read(termActionsProvider)
        .startNewTerm(
          newTerm: _term.text.trim(),
          offices: seated,
          alumniIds: _alumni,
        );
    if (!mounted) return;
    Toast.show(context, 'New term started');
    context.go('/home');
  }

  Future<void> _report() async {
    final org = ref.read(organizationProvider);
    final tasks = ref.read(tasksProvider);
    final events = ref.read(eventsProvider).where((e) => !e.cancelled).toList();
    final expenses = ref.read(expensesProvider);
    final income = ref.read(incomeProvider);
    final members = ref.read(activeMembersProvider);
    final doc = pw.Document();
    pw.Widget row(String a, String b) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(a),
          pw.Text(b, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              org?.name ?? 'Chapter',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Year-end report · ${org?.currentTerm ?? ''}',
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 24),
            row('Active members', '${members.length}'),
            row('Events held', '${events.length}'),
            row(
              'Tasks completed',
              '${tasks.where((t) => t.status == TaskStatus.done).length} of ${tasks.length}',
            ),
            row('Total income', Fmt.money(Ledger.incomeTotal(income))),
            row('Total spent', Fmt.money(Ledger.spentTotal(expenses))),
            row('Closing balance', Fmt.money(Ledger.balance(income, expenses))),
            pw.SizedBox(height: 20),
            pw.Text(
              'Events',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            for (final e in events)
              pw.Text('${Fmt.date(e.startsAt)}  ${e.title}'),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (_) => doc.save(),
      name: 'year-end-report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(roleMapProvider);
    final domains = ref.watch(domainsProvider);
    final domainMap = ref.watch(domainMapProvider);
    final members = ref.watch(activeMembersProvider);
    final offices = _offices(domains);
    final p = context.palette;
    final bearers = members
        .where((m) => roles[m.roleId]?.isOfficeBearer ?? false)
        .toList();

    if (!_seeded && members.isNotEmpty) {
      _seeded = true;
      for (final o in offices) {
        _holders[o.key] = members
            .where(
              (m) =>
                  m.roleId == o.roleId &&
                  (o.domainId == null || m.domainId == o.domainId),
            )
            .firstOrNull
            ?.id;
      }
    }

    return AppPage(
      title: 'Term handover',
      subtitle: 'Pass the baton, keep the history',
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Panel(
                  color: p.amberTint,
                  borderColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: p.amber),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Text(
                          'Everyone keeps their history. Outgoing people are disabled, never deleted. Download the year-end report first.',
                          style: context.text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.lg),
                OutlinedButton.icon(
                  onPressed: _report,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Year-end report (PDF)'),
                ),
                const SizedBox(height: Gap.xl),
                TextField(
                  controller: _term,
                  decoration: const InputDecoration(
                    labelText: 'New term',
                    hintText: '2026-27',
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Text('New cabinet', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < offices.length; i++) ...[
                        if (i > 0) Divider(color: p.line, height: 1),
                        Padding(
                          padding: const EdgeInsets.all(Gap.md),
                          child: MemberPickerField(
                            label: _label(offices[i], roles, domainMap),
                            members: members,
                            selectedIds: [
                              if (_holders[offices[i].key] != null)
                                _holders[offices[i].key]!,
                            ],
                            multiple: false,
                            onChanged: (v) => setState(
                              () => _holders[offices[i].key] = v.isEmpty
                                  ? null
                                  : v.first,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Text('Moving on as alumni', style: context.text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Outgoing office bearers not in the new cabinet. They lose sign-in; their record stays.',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: Gap.md),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final m in bearers)
                        CheckboxListTile(
                          value: _alumni.contains(m.id),
                          onChanged: (v) => setState(
                            () => v == true
                                ? _alumni.add(m.id)
                                : _alumni.remove(m.id),
                          ),
                          title: Text(m.name),
                          subtitle: Text(roles[m.roleId]?.name ?? ''),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : () => _confirm(offices),
                    child: const Text('Start new term'),
                  ),
                ),
                const SizedBox(height: Gap.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
