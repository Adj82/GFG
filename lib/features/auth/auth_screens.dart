import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../data/seed/seed.dart';
import '../../domain/actions/people_actions.dart';

/// Split layout on wide screens: brand slab on the left, form on the right.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.showBack = false});

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  const Expanded(child: _BrandSlab(tall: true)),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(Gap.xxl),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _BrandSlab()),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(Radii.xl),
                        ),
                      ),
                      transform: Matrix4.translationValues(0, -Gap.xl, 0),
                      padding: const EdgeInsets.fromLTRB(
                        Gap.page,
                        Gap.xl + Gap.lg,
                        Gap.page,
                        Gap.xxl,
                      ),
                      child: ContentWidth(max: 460, child: child),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BrandSlab extends ConsumerWidget {
  const _BrandSlab({this.tall = false});

  final bool tall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final org = ref.watch(organizationProvider);
    return Container(
      color: p.forest,
      padding: EdgeInsets.fromLTRB(
        Gap.page + 4,
        tall ? Gap.xxl : Gap.xl,
        Gap.page + 4,
        tall ? Gap.xxl : Gap.xxl + Gap.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: tall
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        mainAxisSize: tall ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Row(
            children: [
              const BrandMark(size: 40, onDark: true),
              const SizedBox(width: Gap.md),
              Text(
                'SocietyOS',
                style: context.text.titleLarge?.copyWith(color: p.onForest),
              ),
            ],
          ),
          if (!tall) const SizedBox(height: Gap.xl) else const Spacer(),
          Text(
            'Run the chapter,\nnot the group chats.',
            style: context.text.displaySmall?.copyWith(
              color: p.onForest,
              fontSize: tall ? 44 : 30,
            ),
          ),
          const SizedBox(height: Gap.md),
          Text(
            '${org?.name ?? 'GFG KIIT Student Chapter'}. Tasks, events, funds and handover in one place.',
            style: context.text.bodyLarge?.copyWith(
              color: p.onForest.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: tall ? Gap.xxl : Gap.xl),
          const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: GridTexture(),
          ),
          if (tall) const Spacer(),
        ],
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  var _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await _signIn(_email.text, _password.text);
  }

  Future<void> _signIn(String email, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).signIn(email, password);
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
    return AuthScaffold(
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sign in', style: context.text.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Use your @${org?.emailDomain ?? 'kiit.ac.in'} email.',
                style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
              ),
              const SizedBox(height: Gap.xl),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (v) =>
                    ref.read(authActionsProvider).validateCampusEmail(v ?? ''),
              ),
              const SizedBox(height: Gap.lg),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter your password.' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: Gap.md),
                _ErrorBanner(_error!),
              ],
              const SizedBox(height: Gap.lg),
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
                    : const Text('Sign in'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot'),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: Gap.sm),
              Panel(
                color: p.greenTint,
                borderColor: Colors.transparent,
                child: Row(
                  children: [
                    Icon(Icons.group_add_rounded, color: p.greenStrong),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New to the chapter?',
                            style: context.text.titleSmall,
                          ),
                          Text(
                            org?.recruitmentOpen == false
                                ? 'Joining is closed right now.'
                                : 'Request to join a domain.',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => context.push('/join'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Join'),
                    ),
                  ],
                ),
              ),
              if (kDemoMode) ...[
                const SizedBox(height: Gap.xl),
                Text('Demo accounts', style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Tap one to sign in. Password for all: ${Seed.password}',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: Gap.md),
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final a in Seed.demoAccounts)
                      ActionChip(
                        label: Text(a.label),
                        onPressed: _busy
                            ? null
                            : () => _signIn(a.email, Seed.password),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: p.redTint,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: p.red, size: 20),
          const SizedBox(width: Gap.sm),
          Expanded(
            child: Text(
              message,
              style: context.text.bodyMedium?.copyWith(color: p.red),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _busy = false;
  var _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).requestPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AuthScaffold(
      child: _sent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EmptyState(
                  icon: Icons.mark_email_read_rounded,
                  title: 'Check your inbox',
                  message:
                      'We sent a reset link to your campus email. It can take a minute to arrive.',
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
                  Text(
                    'Reset your password',
                    style: context.text.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your campus email and we’ll send you a link.',
                    style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
                  ),
                  const SizedBox(height: Gap.xl),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (v) => ref
                        .read(authActionsProvider)
                        .validateCampusEmail(v ?? ''),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: Gap.md),
                    _ErrorBanner(_error!),
                  ],
                  const SizedBox(height: Gap.lg),
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
                        : const Text('Send reset link'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Shown after sign-in when the account isn't active yet (or any more).
class AccountStatusScreen extends ConsumerWidget {
  const AccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentMemberProvider);
    final domains = ref.watch(domainMapProvider);
    final app = me == null
        ? null
        : ref
              .watch(applicationsProvider)
              .where((a) => a.memberId == me.id)
              .firstOrNull;
    final p = context.palette;

    final (icon, title, message) = switch (me?.status) {
      MemberStatus.pending => (
        Icons.hourglass_top_rounded,
        'Your request is with the ${domains[me!.domainId]?.name ?? ''} lead',
        app?.stage == ApplicationStage.interview
            ? 'You’re invited to an interview${app?.interviewAt == null ? '' : ' — see the time below'}. We’ll notify you once there’s a decision.'
            : 'You’ll get access as soon as a lead accepts your request. This usually takes a few days.',
      ),
      MemberStatus.rejected => (
        Icons.do_not_disturb_on_outlined,
        'Your request wasn’t accepted this time',
        'Thanks for applying. You can apply again when the next induction opens.',
      ),
      MemberStatus.disabled => (
        Icons.lock_outline_rounded,
        'This account is no longer active',
        'Your term as an office bearer has ended, so access is closed. Your history is kept safe. Contact the President if this looks wrong.',
      ),
      _ => (
        Icons.help_outline_rounded,
        'Account not found',
        'Sign out and try again.',
      ),
    };

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmptyState(icon: icon, title: title, message: message, compact: true),
          if (app != null && me?.status == MemberStatus.pending) ...[
            Panel(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.workspaces_rounded,
                    label: 'Domain',
                    value: domains[app.domainId]?.name ?? '',
                  ),
                  InfoRow(
                    icon: Icons.timeline_rounded,
                    label: 'Status',
                    value: app.stage.label,
                  ),
                  if (app.interviewAt != null)
                    InfoRow(
                      icon: Icons.event_available_rounded,
                      label: 'Interview',
                      value: _fmtDate(app.interviewAt!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
          ],
          OutlinedButton.icon(
            onPressed: () => ref.read(authActionsProvider).signOut(),
            icon: Icon(Icons.logout_rounded, color: p.ink),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '${d.day} ${m[d.month - 1]}, $h:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
  }
}

/// Forced on first login for accounts created with a temporary password (doc §4).
class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _pw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).changePassword(_pw.text);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final me = ref.watch(currentMemberProvider);
    return AuthScaffold(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, ${me == null ? '' : me.name.split(' ').first}',
              style: context.text.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'You signed in with a temporary password. Choose your own to continue.',
              style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
            ),
            const SizedBox(height: Gap.xl),
            TextFormField(
              controller: _pw,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(
                labelText: 'New password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: passwordProblem,
            ),
            const SizedBox(height: Gap.lg),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
              validator: (v) =>
                  v != _pw.text ? 'The two passwords don’t match.' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: Gap.md),
              _ErrorBanner(_error!),
            ],
            const SizedBox(height: Gap.lg),
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
                  : const Text('Save password'),
            ),
            TextButton(
              onPressed: () => ref.read(authActionsProvider).signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

String? passwordProblem(String? v) {
  final s = v ?? '';
  if (s.length < 8) return 'Use at least 8 characters.';
  if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
    return 'Include a letter and a number.';
  }
  return null;
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: EmptyState(
          icon: Icons.explore_off_rounded,
          title: 'That page doesn’t exist',
          message: 'The link may be old or mistyped.',
          actionLabel: 'Go home',
          onAction: () => context.go('/home'),
        ),
      ),
    );
  }
}
