import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/contribution_grid.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/people_actions.dart';
import '../../domain/activity.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(authUserIdProvider);
    if (id == null) return const SizedBox.shrink();
    return MemberScreen(memberId: id, mine: true);
  }
}

class MemberScreen extends ConsumerWidget {
  const MemberScreen({super.key, required this.memberId, this.mine = false});

  final String memberId;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    final m = ref.watch(memberMapProvider)[memberId];
    if (a == null) return const SizedBox.shrink();
    if (m == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.person_off_rounded,
            title: 'Member not found',
          ),
        ),
      );
    }
    final p = context.palette;
    final roles = ref.watch(roleMapProvider);
    final domains = ref.watch(domainMapProvider);
    final role = roles[m.roleId];
    final days = ref.watch(activityProvider(m.id));
    final events = ref.watch(attendedEventsProvider(m.id));
    final done = ref
        .watch(tasksProvider)
        .where(
          (t) => t.assigneeIds.contains(m.id) && t.status == TaskStatus.done,
        )
        .length;
    final streak = Activity.streak(days);
    final total = days.values.fold<int>(0, (s, v) => s + v);
    final canManage = a.canManageMember(m);
    final isMe = m.id == a.me.id;

    return AppPage(
      title: isMe ? 'My profile' : 'Profile',
      subtitle: isMe ? null : m.name,
      actions: [
        if (isMe)
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
      ],
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(m.name, size: 72),
                    const SizedBox(width: Gap.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: context.text.headlineSmall),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (role != null)
                                Pill(role.name, tone: Tone.green(context)),
                              if (domains[m.domainId] != null)
                                Pill(
                                  domains[m.domainId]!.name,
                                  tone: Tone.neutral(context),
                                ),
                              if (m.status == MemberStatus.disabled)
                                Pill('Alumni', tone: Tone.amber(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (m.bio.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  Text(
                    m.bio,
                    style: context.text.bodyLarge?.copyWith(
                      color: p.inkMuted,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: Gap.xl),
                Row(
                  children: [
                    Expanded(
                      child: Panel(
                        child: Stat(value: '$streak', label: 'Day streak'),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Panel(
                        child: Stat(value: '$done', label: 'Tasks done'),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Panel(
                        child: Stat(value: '${events.length}', label: 'Events'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xl),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total contributions this term',
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: Gap.md),
                      ContributionGrid(days: days),
                      const SizedBox(height: Gap.sm),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: HeatLegend(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Panel(
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Roll number',
                        value: m.rollNo,
                      ),
                      InfoRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: m.email,
                      ),
                      if (m.phone.isNotEmpty)
                        InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: m.phone,
                        ),
                      if (m.branch.isNotEmpty || m.year != null)
                        InfoRow(
                          icon: Icons.school_outlined,
                          label: 'Studying',
                          value: [
                            if (m.year != null) 'Year ${m.year}',
                            if (m.branch.isNotEmpty) m.branch,
                          ].join(' · '),
                        ),
                      if (m.github.isNotEmpty)
                        InfoRow(
                          icon: Icons.code_rounded,
                          label: 'GitHub',
                          value: m.github,
                          onTap: () => launchUrl(
                            Uri.parse(
                              m.github.startsWith('http')
                                  ? m.github
                                  : 'https://github.com/${m.github}',
                            ),
                          ),
                        ),
                      if (m.linkedin.isNotEmpty)
                        InfoRow(
                          icon: Icons.link_rounded,
                          label: 'LinkedIn',
                          value: m.linkedin,
                          onTap: () => launchUrl(
                            Uri.parse(
                              m.linkedin.startsWith('http')
                                  ? m.linkedin
                                  : 'https://linkedin.com/in/${m.linkedin}',
                            ),
                          ),
                        ),
                      InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Joined',
                        value: Fmt.monthYear(m.joinedAt),
                      ),
                    ],
                  ),
                ),
                if (m.skills.isNotEmpty) ...[
                  const SizedBox(height: Gap.xl),
                  Text('Skills', style: context.text.titleMedium),
                  const SizedBox(height: Gap.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in m.skills)
                        Pill(s, tone: Tone.neutral(context)),
                    ],
                  ),
                ],
                if (m.history.isNotEmpty) ...[
                  const SizedBox(height: Gap.xl),
                  Text('Past roles', style: context.text.titleMedium),
                  const SizedBox(height: Gap.md),
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < m.history.length; i++) ...[
                          if (i > 0) Divider(color: p.line, height: 1),
                          ListTile(
                            leading: const Icon(Icons.history_rounded),
                            title: Text(
                              roles[m.history[i].roleId]?.name ??
                                  m.history[i].roleId,
                            ),
                            subtitle: Text(
                              '${m.history[i].term}${domains[m.history[i].domainId] == null ? '' : ' · ${domains[m.history[i].domainId]!.name}'}',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (events.isNotEmpty) ...[
                  const SizedBox(height: Gap.xl),
                  Text('Events attended', style: context.text.titleMedium),
                  const SizedBox(height: Gap.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in events.take(12))
                        ActionChip(
                          label: Text(e.title),
                          onPressed: () => context.push('/events/${e.id}'),
                        ),
                    ],
                  ),
                ],
                if (canManage) ...[
                  const SizedBox(height: Gap.xl),
                  Text('Manage', style: context.text.titleMedium),
                  const SizedBox(height: Gap.md),
                  _ManageCard(member: m),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ManageCard extends ConsumerWidget {
  const _ManageCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider)!;
    final p = context.palette;
    final acts = ref.read(peopleActionsProvider);
    final m = member;
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (a.can(Permission.manageMembers))
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('Change role'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showFormSheet<void>(
                context,
                builder: (_) => _RoleForm(member: m),
              ),
            ),
          if (a.can(Permission.manageMembers))
            Divider(color: p.line, height: 1),
          ListTile(
            leading: Icon(
              m.status == MemberStatus.disabled
                  ? Icons.lock_open_rounded
                  : Icons.block_rounded,
              color: m.status == MemberStatus.disabled ? null : p.red,
            ),
            title: Text(
              m.status == MemberStatus.disabled
                  ? 'Re-enable account'
                  : 'Disable account',
              style: TextStyle(
                color: m.status == MemberStatus.disabled ? null : p.red,
              ),
            ),
            subtitle: const Text('History is always kept.'),
            onTap: () async {
              final off = m.status != MemberStatus.disabled;
              final ok = await confirmDialog(
                context,
                title: off ? 'Disable ${m.name}?' : 'Re-enable ${m.name}?',
                message: off
                    ? 'They can no longer sign in. Their tasks, attendance and history stay.'
                    : 'They can sign in again.',
                confirmLabel: off ? 'Disable' : 'Re-enable',
                destructive: off,
              );
              if (ok) await acts.setDisabled(m, off);
            },
          ),
        ],
      ),
    );
  }
}

class _RoleForm extends ConsumerStatefulWidget {
  const _RoleForm({required this.member});

  final Member member;

  @override
  ConsumerState<_RoleForm> createState() => _RoleFormState();
}

class _RoleFormState extends ConsumerState<_RoleForm> {
  late String _roleId = widget.member.roleId;
  late String? _domainId = widget.member.domainId;

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(rolesProvider).toList()
      ..sort((a, b) => b.rank.compareTo(a.rank));
    final domains = ref.watch(domainsProvider);
    final domainMap = ref.watch(domainMapProvider);
    return FormSheet(
      title: 'Change role',
      subtitle: widget.member.name,
      submitLabel: 'Save role',
      onSubmit: () async {
        final role = ref.read(roleMapProvider)[_roleId];
        Department? dept;
        if (role?.scope == RoleScope.department) {
          dept = _roleId == 'technical_head'
              ? Department.technical
              : Department.nonTechnical;
        } else {
          dept = domainMap[_domainId]?.department;
        }
        await ref
            .read(peopleActionsProvider)
            .changeRole(
              widget.member,
              roleId: _roleId,
              domainId: _domainId,
              dept: dept,
            );
        if (!context.mounted) return;
        Navigator.pop(context);
        Toast.show(context, 'Role updated');
      },
      children: [
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
        DropdownButtonFormField<String?>(
          initialValue: _domainId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Domain'),
          items: [
            const DropdownMenuItem(value: null, child: Text('No domain')),
            for (final d in domains)
              DropdownMenuItem(value: d.id, child: Text(d.name)),
          ],
          onChanged: (v) => setState(() => _domainId = v),
        ),
      ],
    );
  }
}
