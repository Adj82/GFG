import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/repositories/repository.dart';
import '../../domain/actions/people_actions.dart';
import '../../domain/default_roles.dart';

final _domainFilter = StateProvider<String?>((ref) => null);
final _showFormer = StateProvider<bool>((ref) => false);

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  var _q = '';

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final roles = ref.watch(roleMapProvider);
    final domains = ref.watch(domainsProvider);
    final domainMap = ref.watch(domainMapProvider);
    final filter = ref.watch(_domainFilter);
    final former = ref.watch(_showFormer);
    final pending = ref.watch(pendingRequestsProvider).length;
    final canAdd = a.can(Permission.manageMembers);

    var list = ref
        .watch(membersProvider)
        .where((m) => former ? m.status == MemberStatus.disabled : m.isActive)
        .toList();
    if (filter != null) list = list.where((m) => m.domainId == filter).toList();
    if (_q.isNotEmpty) {
      list = list
          .where(
            (m) =>
                m.name.toLowerCase().contains(_q) ||
                m.email.toLowerCase().contains(_q),
          )
          .toList();
    }
    list.sort((x, y) {
      final r = (roles[y.roleId]?.rank ?? 0).compareTo(
        roles[x.roleId]?.rank ?? 0,
      );
      return r != 0 ? r : x.name.compareTo(y.name);
    });

    return AppPage(
      title: 'People',
      subtitle: former ? 'Alumni and past members' : '${list.length} active',
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => _addMember(context),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add member'),
            )
          : null,
      slivers: [
        if (pending > 0)
          PagePad(
            top: Gap.sm,
            child: ContentWidth(
              child: Panel(
                onTap: () => context.push('/people/requests'),
                color: p.amberTint,
                borderColor: Colors.transparent,
                child: Row(
                  children: [
                    Icon(Icons.how_to_reg_rounded, color: p.amber),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Text(
                        '$pending join ${pending == 1 ? 'request' : 'requests'} to review',
                        style: context.text.titleSmall,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.amber),
                  ],
                ),
              ),
            ),
          )
        else if (a.can(Permission.approveMembers))
          PagePad(
            top: Gap.sm,
            child: ContentWidth(
              child: Panel(
                onTap: () => context.push('/people/requests'),
                child: Row(
                  children: [
                    const Icon(Icons.how_to_reg_rounded),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Text(
                        'Recruitment and join requests',
                        style: context.text.titleSmall,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.page, Gap.lg, Gap.page, 0),
            child: TextField(
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by name or roll number',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: Gap.md),
            child: FilterBar<String?>(
              values: [null, ...domains.map((d) => d.id)],
              selected: filter,
              label: (id) =>
                  id == null ? 'All domains' : (domainMap[id]?.name ?? ''),
              onSelected: (v) => ref.read(_domainFilter.notifier).state = v,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.page),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => ref.read(_showFormer.notifier).state = !former,
                child: Text(former ? 'Show active members' : 'Show alumni'),
              ),
            ),
          ),
        ),
        if (list.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.group_off_rounded,
              title: 'No one found',
              compact: true,
            ),
          )
        else
          PagePad(
            child: ContentWidth(
              child: Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) Divider(color: p.line, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Gap.lg,
                          vertical: 2,
                        ),
                        leading: Avatar(list[i].name, size: 40),
                        title: Text(list[i].name),
                        subtitle: Text(
                          [
                            roles[list[i].roleId]?.name ?? '',
                            if (domainMap[list[i].domainId] != null)
                              domainMap[list[i].domainId]!.name,
                          ].where((s) => s.isNotEmpty).join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/people/${list[i].id}'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addMember(BuildContext context) async {
    final result = await showFormSheet<String>(
      context,
      builder: (_) => const _AddMemberForm(),
    );
    if (result != null && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Member added'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share this temporary password. They will be asked to change it on first sign-in.',
              ),
              const SizedBox(height: Gap.md),
              SelectableText(
                result,
                style: Theme.of(c).textTheme.headlineSmall,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }
}

class _AddMemberForm extends ConsumerStatefulWidget {
  const _AddMemberForm();

  @override
  ConsumerState<_AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends ConsumerState<_AddMemberForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  String _roleId = DefaultRoles.member;
  String? _domainId;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final roles = ref.read(roleMapProvider);
    final needsDomain =
        roles[_roleId]?.scope == RoleScope.domain ||
        _roleId == DefaultRoles.member;
    if (needsDomain && _domainId == null) {
      return Toast.show(context, 'Pick a domain', error: true);
    }
    setState(() => _busy = true);
    try {
      final dom = ref.read(domainMapProvider)[_domainId];
      final temp = await ref
          .read(peopleActionsProvider)
          .addMember(
            name: _name.text,
            email: _email.text,
            roleId: _roleId,
            domainId: _domainId,
            dept: roles[_roleId]?.scope == RoleScope.department
                ? (_roleId == DefaultRoles.technicalHead
                      ? Department.technical
                      : Department.nonTechnical)
                : dom?.department,
          );
      if (mounted) Navigator.pop(context, temp);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Toast.show(
          context,
          e is AuthFailure ? e.message : 'Could not add member',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(rolesProvider).toList()
      ..sort((a, b) => b.rank.compareTo(a.rank));
    final domains = ref.watch(domainsProvider);
    final org = ref.watch(organizationProvider);
    return FormSheet(
      formKey: _form,
      title: 'Add a member',
      subtitle: 'Creates their account with a temporary password.',
      submitLabel: 'Create account',
      busy: _busy,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
          validator: (v) => requiredText(v, 'Enter their name.'),
        ),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Campus email',
            hintText: '2205140@${org?.emailDomain ?? 'kiit.ac.in'}',
          ),
          validator: (v) =>
              ref.read(authActionsProvider).validateCampusEmail(v ?? ''),
        ),
        DropdownButtonFormField<String>(
          initialValue: _roleId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Role'),
          items: [
            for (final r in roles)
              DropdownMenuItem(value: r.id, child: Text(r.name)),
          ],
          onChanged: (v) => setState(() => _roleId = v ?? _roleId),
        ),
        DropdownButtonFormField<String>(
          initialValue: _domainId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Domain'),
          items: [
            for (final d in domains)
              DropdownMenuItem(value: d.id, child: Text(d.name)),
          ],
          onChanged: (v) => setState(() => _domainId = v),
        ),
      ],
    );
  }
}
