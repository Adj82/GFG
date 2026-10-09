import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/page.dart';
import '../../data/providers.dart';
import '../../domain/actions/people_actions.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: ref.read(currentMemberProvider)?.name,
  );
  late final _phone = TextEditingController(
    text: ref.read(currentMemberProvider)?.phone,
  );
  late final _branch = TextEditingController(
    text: ref.read(currentMemberProvider)?.branch,
  );
  late final _bio = TextEditingController(
    text: ref.read(currentMemberProvider)?.bio,
  );
  late final _skills = TextEditingController(
    text: ref.read(currentMemberProvider)?.skills.join(', '),
  );
  late final _github = TextEditingController(
    text: ref.read(currentMemberProvider)?.github,
  );
  late final _linkedin = TextEditingController(
    text: ref.read(currentMemberProvider)?.linkedin,
  );
  late int? _year = ref.read(currentMemberProvider)?.year;
  var _busy = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _branch,
      _bio,
      _skills,
      _github,
      _linkedin,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final me = ref.read(currentMemberProvider);
    if (me == null || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await ref
        .read(authActionsProvider)
        .updateProfile(
          me.copyWith(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            branch: _branch.text.trim(),
            bio: _bio.text.trim(),
            year: _year,
            skills: _skills.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            github: _github.text.trim(),
            linkedin: _linkedin.text.trim(),
          ),
        );
    if (!mounted) return;
    Toast.show(context, 'Profile saved');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Edit profile',
      slivers: [
        PagePad(
          child: ContentWidth(
            child: Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (v) => requiredText(v, 'Your name is required.'),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _bio,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'About you',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: Gap.lg),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _branch,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                          ),
                        ),
                      ),
                      const SizedBox(width: Gap.md),
                      SizedBox(
                        width: 130,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _year,
                          decoration: const InputDecoration(labelText: 'Year'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('—'),
                            ),
                            for (final y in [1, 2, 3, 4])
                              DropdownMenuItem(
                                value: y,
                                child: Text('Year $y'),
                              ),
                          ],
                          onChanged: (v) => setState(() => _year = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _skills,
                    decoration: const InputDecoration(
                      labelText: 'Skills',
                      hintText: 'Flutter, Firebase, Figma',
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _github,
                    decoration: const InputDecoration(
                      labelText: 'GitHub username or link',
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _linkedin,
                    decoration: const InputDecoration(
                      labelText: 'LinkedIn username or link',
                    ),
                  ),
                  const SizedBox(height: Gap.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _save,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
