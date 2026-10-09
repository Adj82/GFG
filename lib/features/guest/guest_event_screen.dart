import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/guest_actions.dart';
import '../../domain/registration_rules.dart';

/// Public view of one event, with the register button.
class GuestEventScreen extends ConsumerWidget {
  const GuestEventScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final event = ref
        .watch(eventsProvider)
        .where((e) => e.id == eventId && e.isPublic)
        .firstOrNull;
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'This event isn’t available',
            message: 'It may have been removed or is for members only.',
          ),
        ),
      );
    }
    final domains = ref.watch(domainMapProvider);
    final regs = ref.watch(eventRegistrationsProvider(event.id)).length;
    final mine = ref.watch(myRegistrationProvider(event.id));
    final left = RegistrationRules.spotsLeft(event, regs);
    final block = RegistrationRules.blockFor(
      event,
      guestCount: regs,
      alreadyRegistered: mine != null,
    );
    final past = event.isPast();
    final live = event.isLive();
    final me = ref.watch(guestProfileProvider);
    final leads =
        mine != null &&
        me != null &&
        mine.email == me.email.trim().toLowerCase();

    String when() {
      final same =
          event.startsAt.year == event.endsAt.year &&
          event.startsAt.month == event.endsAt.month &&
          event.startsAt.day == event.endsAt.day;
      return same
          ? '${Fmt.weekdayDate(event.startsAt)}, ${Fmt.time(event.startsAt)} to ${Fmt.time(event.endsAt)}'
          : '${Fmt.dateTime(event.startsAt)} to ${Fmt.dateTime(event.endsAt)}';
    }

    Widget bottom() {
      if (mine != null && !past) {
        return _Bar(
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: p.greenStrong),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mine.isTeam
                          ? 'Team ${mine.teamName} is registered'
                          : 'You’re registered',
                      style: context.text.titleSmall,
                    ),
                    Text(
                      leads
                          ? 'Quote ${mine.reference} at the door'
                          : '${mine.name} registered your team. Ref ${mine.reference}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              if (leads)
                TextButton(
                  onPressed: () async {
                    final ok = await confirmDialog(
                      context,
                      title: mine.isTeam
                          ? 'Cancel your team’s registration?'
                          : 'Give up your seat?',
                      message: mine.isTeam
                          ? 'The whole team loses its place. You can register again while slots are left.'
                          : 'You can register again while seats are left.',
                      confirmLabel: 'Cancel registration',
                      destructive: true,
                    );
                    if (ok) await ref.read(guestActionsProvider).cancel(mine);
                  },
                  child: const Text('Cancel'),
                ),
            ],
          ),
        );
      }
      if (block != null) {
        return _Bar(
          child: Row(
            children: [
              Icon(
                past ? Icons.history_rounded : Icons.event_busy_rounded,
                color: p.inkMuted,
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Text(block.message, style: context.text.titleSmall),
              ),
            ],
          ),
        );
      }
      return _Bar(
        child: FilledButton(
          onPressed: () => showRegisterSheet(context, event),
          child: Text(live ? 'Register now' : 'Register for this event'),
        ),
      );
    }

    return AppPage(
      title: event.title,
      subtitle:
          '${event.type.label}${event.domainId == null ? '' : ' · ${domains[event.domainId]?.name ?? ''}'}',
      bottomBar: bottom(),
      slivers: [
        PagePad(
          top: Gap.sm,
          child: ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (live)
                      Pill(
                        'Live now',
                        tone: Tone.green(context),
                        icon: Icons.circle,
                      ),
                    if (event.isTeam)
                      Pill(
                        event.teamLabel,
                        tone: Tone.blue(context),
                        icon: Icons.groups_rounded,
                      ),
                    if (!past)
                      Pill(
                        left == null
                            ? 'Open to everyone'
                            : left == 0
                            ? 'Full'
                            : '${Fmt.plural(left, event.isTeam ? 'team slot' : 'seat')} left',
                        tone: left == 0
                            ? Tone.red(context)
                            : Tone.neutral(context),
                        icon: Icons.event_seat_rounded,
                      ),
                    if (!past && !live)
                      Pill(
                        Fmt.countdown(event.startsAt),
                        tone: Tone.neutral(context),
                        icon: Icons.schedule_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                Panel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.lg,
                    vertical: Gap.sm,
                  ),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.event_rounded,
                        label: 'When',
                        value: when(),
                      ),
                      Divider(height: 1, color: p.line),
                      InfoRow(
                        icon: Icons.place_rounded,
                        label: 'Where',
                        value: event.venue,
                      ),
                      Divider(height: 1, color: p.line),
                      InfoRow(
                        icon: event.isTeam
                            ? Icons.groups_rounded
                            : Icons.person_rounded,
                        label: 'Who can join',
                        value: event.isTeam
                            ? '${event.teamLabel}. One person registers the team and adds the rest.'
                            : 'Solo. Register yourself.',
                      ),
                    ],
                  ),
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  Text('About', style: context.text.titleMedium),
                  const SizedBox(height: Gap.sm),
                  Text(event.description, style: context.text.bodyLarge),
                ],
                if (past && event.outcome.isNotEmpty) ...[
                  const SizedBox(height: Gap.lg),
                  Panel(
                    color: p.greenTint,
                    borderColor: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How it went', style: context.text.titleSmall),
                        const SizedBox(height: 4),
                        Text(event.outcome, style: context.text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Gap.page,
        Gap.md,
        Gap.page,
        Gap.md + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: ContentWidth(child: child),
    );
  }
}

Future<void> showRegisterSheet(BuildContext context, SocietyEvent event) =>
    showFormSheet<void>(context, builder: (_) => _RegisterForm(event: event));

class _MemberFields {
  final name = TextEditingController();
  final email = TextEditingController();
  final roll = TextEditingController();

  void dispose() {
    name.dispose();
    email.dispose();
    roll.dispose();
  }
}

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm({required this.event});

  final SocietyEvent event;

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  final _form = GlobalKey<FormState>();
  late final GuestProfile? _saved = ref.read(guestProfileProvider);
  late final _name = TextEditingController(text: _saved?.name ?? '');
  late final _email = TextEditingController(text: _saved?.email ?? '');
  late final _roll = TextEditingController(text: _saved?.rollNo ?? '');
  late final _college = TextEditingController(text: _saved?.college ?? 'KIIT');
  final _team = TextEditingController();
  late final List<_MemberFields> _members = [
    if (widget.event.isTeam)
      for (var i = 0; i < widget.event.teamMin - 1; i++) _MemberFields(),
  ];
  var _busy = false;
  String? _error;

  SocietyEvent get _e => widget.event;

  @override
  void dispose() {
    for (final c in [_name, _email, _roll, _college, _team]) {
      c.dispose();
    }
    for (final m in _members) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(guestActionsProvider)
          .register(
            _e,
            GuestProfile(
              name: _name.text,
              email: _email.text,
              rollNo: _roll.text,
              college: _college.text,
            ),
            teamName: _team.text,
            members: [
              for (final m in _members)
                TeamMember(
                  name: m.name.text,
                  email: m.email.text,
                  rollNo: m.roll.text,
                ),
            ],
          );
      if (!mounted) return;
      Navigator.pop(context);
      Toast.show(
        context,
        _e.isTeam
            ? 'Your team is registered. See you there!'
            : 'You’re in. See you there!',
      );
    } on StateError catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final team = _e.isTeam;
    final mates = _e.teamMax - 1;

    return FormSheet(
      formKey: _form,
      title: team ? 'Register your team' : 'Register',
      subtitle: team ? '${_e.title} · ${_e.teamLabel}' : _e.title,
      submitLabel: team ? 'Register team' : 'Confirm my seat',
      busy: _busy,
      onSubmit: _submit,
      children: [
        if (team)
          TextFormField(
            controller: _team,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Team name'),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Give your team a name.' : null,
          ),
        if (team)
          Text('You are the team leader', style: context.text.titleSmall),
        TextFormField(
          controller: _name,
          autofocus: !team && _saved == null,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(labelText: 'Your full name'),
          validator: RegistrationRules.validateName,
        ),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: 'Your email',
            helperText: team
                ? 'Updates about the team come here.'
                : 'We’ll use it to recognise you at the door.',
          ),
          validator: RegistrationRules.validateEmail,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _roll,
                decoration: const InputDecoration(
                  labelText: 'Roll no. (optional)',
                ),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: TextFormField(
                controller: _college,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'College'),
              ),
            ),
          ],
        ),
        if (team) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Teammates (${_members.length} of $mates)',
                  style: context.text.titleSmall,
                ),
              ),
              Text('At least ${_e.teamMin - 1}', style: context.text.bodySmall),
            ],
          ),
          for (var i = 0; i < _members.length; i++)
            Panel(
              color: p.surfaceAlt,
              borderColor: Colors.transparent,
              padding: const EdgeInsets.all(Gap.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Teammate ${i + 1}',
                          style: context.text.labelLarge,
                        ),
                      ),
                      if (_members.length > _e.teamMin - 1)
                        IconButton(
                          tooltip: 'Remove teammate ${i + 1}',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => setState(() {
                            _members.removeAt(i).dispose();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  TextFormField(
                    controller: _members[i].name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: RegistrationRules.validateName,
                  ),
                  const SizedBox(height: Gap.md),
                  TextFormField(
                    controller: _members[i].email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: RegistrationRules.validateEmail,
                  ),
                  const SizedBox(height: Gap.md),
                  TextFormField(
                    controller: _members[i].roll,
                    decoration: const InputDecoration(
                      labelText: 'Roll no. (optional)',
                    ),
                  ),
                ],
              ),
            ),
          if (_members.length < mates)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _members.add(_MemberFields())),
                icon: const Icon(Icons.person_add_alt_rounded),
                label: const Text('Add a teammate'),
              ),
            ),
        ],
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
