import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/providers.dart';
import '../../data/seed/seed.dart';
import '../../domain/actions/people_actions.dart';
import '../auth/auth_screens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final mode = ref.watch(themeModeProvider);
    final org = ref.watch(organizationProvider);

    return AppPage(
      title: 'Settings',
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Auto'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) =>
                        ref.read(themeModeProvider.notifier).set(s.first),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Text('Account', style: context.text.titleMedium),
                const SizedBox(height: Gap.md),
                Panel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline_rounded),
                        title: const Text('Change password'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => showFormSheet<void>(
                          context,
                          builder: (_) => const _PasswordForm(),
                        ),
                      ),
                      Divider(color: p.line, height: 1),
                      ListTile(
                        leading: Icon(Icons.logout_rounded, color: p.red),
                        title: Text('Sign out', style: TextStyle(color: p.red)),
                        onTap: () async {
                          final ok = await confirmDialog(
                            context,
                            title: 'Sign out?',
                            message: 'You can sign back in any time.',
                            confirmLabel: 'Sign out',
                          );
                          if (ok) await ref.read(authActionsProvider).signOut();
                        },
                      ),
                    ],
                  ),
                ),
                if (kDemoMode) ...[
                  const SizedBox(height: Gap.xl),
                  Text('Demo', style: context.text.titleMedium),
                  const SizedBox(height: Gap.md),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data lives on this device only until the backend is connected.',
                          style: context.text.bodyMedium,
                        ),
                        const SizedBox(height: Gap.md),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset demo data'),
                          onPressed: () async {
                            final ok = await confirmDialog(
                              context,
                              title: 'Reset all data?',
                              message:
                                  'Everything you added will be replaced with fresh sample data and you will be signed out.',
                              confirmLabel: 'Reset',
                              destructive: true,
                            );
                            if (!ok) return;
                            final store = ref.read(localStoreProvider);
                            await ref.read(authActionsProvider).signOut();
                            await store.clear();
                            await Seed.run(store);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Gap.xl),
                Center(
                  child: Text(
                    '${org?.name ?? 'SocietyOS'} · ${org?.currentTerm ?? ''}',
                    style: context.text.bodySmall,
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

class _PasswordForm extends ConsumerStatefulWidget {
  const _PasswordForm();

  @override
  ConsumerState<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends ConsumerState<_PasswordForm> {
  final _form = GlobalKey<FormState>();
  final _a = TextEditingController();
  final _b = TextEditingController();

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormSheet(
    formKey: _form,
    title: 'Change password',
    submitLabel: 'Update password',
    onSubmit: () async {
      if (!_form.currentState!.validate()) return;
      await ref.read(authActionsProvider).changePassword(_a.text);
      if (!context.mounted) return;
      Navigator.pop(context);
      Toast.show(context, 'Password updated');
    },
    children: [
      TextFormField(
        controller: _a,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'New password'),
        validator: (v) => passwordProblem(v ?? ''),
      ),
      TextFormField(
        controller: _b,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Repeat password'),
        validator: (v) => v == _a.text ? null : 'Passwords don’t match.',
      ),
    ],
  );
}

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final entries = ref.watch(auditProvider).toList()
      ..sort((x, y) => y.at.compareTo(x.at));
    return AppPage(
      title: 'Audit log',
      subtitle:
          '${Fmt.plural(entries.length, 'entry', 'entries')} · append-only',
      slivers: [
        if (entries.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.history_rounded,
              title: 'Nothing recorded yet',
            ),
          )
        else
          PagePad(
            child: ContentWidth(
              child: Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) Divider(color: p.line, height: 1),
                      ListTile(
                        leading: Avatar(
                          memberName(members, entries[i].actorId),
                          size: 34,
                        ),
                        title: Text(entries[i].summary),
                        subtitle: Text(
                          '${entries[i].action} · ${Fmt.dateTime(entries[i].at)}',
                        ),
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
}
