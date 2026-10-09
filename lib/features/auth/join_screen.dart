import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/icons.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/people_actions.dart';
import 'auth_screens.dart';

/// Member sign-up (doc §4): campus email, choose a domain, wait for approval.
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _branch = TextEditingController();
  final _why = TextEditingController();
  final _experience = TextEditingController();
  final _portfolio = TextEditingController();
  String? _domainId;
  int _year = 1;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _password,
      _branch,
      _why,
      _experience,
      _portfolio,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_domainId == null) {
      setState(() => _error = 'Pick the domain you want to join.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authActionsProvider)
          .applyToJoin(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            domainId: _domainId!,
            year: _year,
            branch: _branch.text,
            why: _why.text,
            experience: _experience.text,
            portfolio: _portfolio.text,
          );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final org = ref.watch(organizationProvider);
    final domains = ref.watch(domainsProvider);
    final closed = org != null && !org.recruitmentOpen;

    return AuthScaffold(
      child: closed
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'Joining is closed right now',
                  message:
                      'Induction opens at the start of each term. Follow the chapter’s announcements to catch the next one.',
                  compact: true,
                ),
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to sign in'),
                ),
              ],
            )
          : Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Sign in'),
                    ),
                  ),
                  Text('Request to join', style: context.text.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    org?.recruitmentNote.isNotEmpty == true
                        ? org!.recruitmentNote
                        : 'A lead from your domain will review your request.',
                    style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
                  ),
                  const SizedBox(height: Gap.xl),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => requiredText(v, 'Enter your name.'),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Campus email',
                      hintText: '2405xxx@${org?.emailDomain ?? 'kiit.ac.in'}',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (v) => ref
                        .read(authActionsProvider)
                        .validateCampusEmail(v ?? ''),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Create a password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: passwordProblem,
                  ),
                  const SizedBox(height: Gap.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _year,
                          decoration: const InputDecoration(labelText: 'Year'),
                          items: [
                            for (final y in [1, 2, 3, 4])
                              DropdownMenuItem(
                                value: y,
                                child: Text('Year $y'),
                              ),
                          ],
                          onChanged: (v) => setState(() => _year = v ?? 1),
                        ),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: TextFormField(
                          controller: _branch,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                            hintText: 'CSE',
                          ),
                          validator: (v) => requiredText(v, 'Add your branch.'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.xl),
                  FieldLabel(
                    'Which domain do you want to join?',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final dept in Department.values) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: Gap.sm,
                              bottom: Gap.sm,
                            ),
                            child: Text(
                              dept.label,
                              style: context.text.labelMedium?.copyWith(
                                color: p.inkFaint,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: Gap.sm,
                            runSpacing: Gap.sm,
                            children: [
                              for (final d in domains.where(
                                (d) => d.department == dept,
                              ))
                                ChoiceChip(
                                  avatar: Icon(
                                    AppIcons.domain(d.icon),
                                    size: 16,
                                  ),
                                  label: Text(d.name),
                                  selected: _domainId == d.id,
                                  showCheckmark: false,
                                  onSelected: (_) =>
                                      setState(() => _domainId = d.id),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: Gap.xl),
                  TextFormField(
                    controller: _why,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Why do you want to join?',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().length < 20)
                        ? 'Write at least a couple of sentences.'
                        : null,
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _experience,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'What have you built or learned? (optional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _portfolio,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'GitHub, portfolio or profile link (optional)',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: Gap.md),
                    Container(
                      padding: const EdgeInsets.all(Gap.md),
                      decoration: BoxDecoration(
                        color: p.redTint,
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: p.red,
                            size: 20,
                          ),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: Text(
                              _error!,
                              style: context.text.bodyMedium?.copyWith(
                                color: p.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Gap.xl),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: p.inkMuted,
                            ),
                          )
                        : const Text('Send request'),
                  ),
                ],
              ),
            ),
    );
  }
}
