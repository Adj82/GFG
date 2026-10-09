import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/forms.dart';
import '../../core/widgets/icons.dart';
import '../../core/widgets/page.dart';
import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';

final _cat = StateProvider<VaultCategory?>((ref) => null);

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    if (a == null) return const SizedBox.shrink();
    final p = context.palette;
    final members = ref.watch(memberMapProvider);
    final cat = ref.watch(_cat);
    final all = ref.watch(vaultProvider).toList()
      ..sort((x, y) => y.addedAt.compareTo(x.addedAt));
    final items = cat == null
        ? all
        : all.where((v) => v.category == cat).toList();
    final canManage = a.can(Permission.manageVault);

    return AppPage(
      title: 'Vault',
      subtitle: 'Shared links and files',
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => showFormSheet<void>(
                context,
                builder: (_) => const _VaultForm(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            )
          : null,
      slivers: [
        SliverToBoxAdapter(
          child: FilterBar<VaultCategory?>(
            values: [null, ...VaultCategory.values],
            selected: cat,
            label: (c) => c?.label ?? 'All',
            onSelected: (v) => ref.read(_cat.notifier).state = v,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: Gap.md)),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'Nothing here yet',
              message: canManage
                  ? 'Add the brand kit, certificate templates and shared logins.'
                  : 'Leads will share resources here.',
            ),
          )
        else
          PagePad(
            child: ContentWidth(
              child: Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) Divider(color: p.line, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Gap.lg,
                          vertical: 4,
                        ),
                        leading: IconTile(
                          AppIcons.vault(items[i].category),
                          size: 40,
                        ),
                        title: Text(items[i].title),
                        subtitle: Text(
                          [
                            items[i].category.label,
                            if (items[i].fileName != null)
                              '${items[i].fileName} · ${Fmt.fileSize(items[i].sizeBytes ?? 0)}'
                            else
                              'Link',
                            memberName(members, items[i].addedBy),
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: canManage
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () async {
                                  final ok = await confirmDialog(
                                    context,
                                    title: 'Remove “${items[i].title}”?',
                                    message: 'It disappears for everyone.',
                                    confirmLabel: 'Remove',
                                    destructive: true,
                                  );
                                  if (ok) {
                                    await ref
                                        .read(vaultActionsProvider)
                                        .delete(items[i]);
                                  }
                                },
                              )
                            : const Icon(Icons.open_in_new_rounded, size: 18),
                        onTap: items[i].url.isEmpty
                            ? () => Toast.show(
                                context,
                                'Files open once storage is connected',
                              )
                            : () => launchUrl(Uri.parse(items[i].url)),
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

class _VaultForm extends ConsumerStatefulWidget {
  const _VaultForm();

  @override
  ConsumerState<_VaultForm> createState() => _VaultFormState();
}

class _VaultFormState extends ConsumerState<_VaultForm> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _desc = TextEditingController();
  VaultCategory _category = VaultCategory.values.first;
  var _isFile = false;
  PlatformFile? _file;
  int _fileSize = 0;

  @override
  void dispose() {
    for (final c in [_title, _url, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_isFile && _file == null) {
      return Toast.show(context, 'Choose a file', error: true);
    }
    final acts = ref.read(vaultActionsProvider);
    if (_isFile) {
      await acts.addFile(
        title: _title.text,
        fileName: _file!.name,
        sizeBytes: _fileSize,
        localPath: _file!.path,
        category: _category,
        description: _desc.text,
      );
    } else {
      await acts.addLink(
        title: _title.text,
        url: _url.text,
        category: _category,
        description: _desc.text,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    Toast.show(context, 'Added to the vault');
  }

  @override
  Widget build(BuildContext context) => FormSheet(
    formKey: _form,
    title: 'Add to vault',
    submitLabel: 'Add',
    onSubmit: _submit,
    children: [
      SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: false,
            icon: Icon(Icons.link_rounded),
            label: Text('Link'),
          ),
          ButtonSegment(
            value: true,
            icon: Icon(Icons.attach_file_rounded),
            label: Text('File'),
          ),
        ],
        selected: {_isFile},
        onSelectionChanged: (s) => setState(() => _isFile = s.first),
      ),
      TextFormField(
        controller: _title,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Title'),
        validator: (v) => requiredText(v, 'Give it a title.'),
      ),
      if (_isFile)
        OutlinedButton.icon(
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_file?.name ?? 'Choose a file'),
          onPressed: () async {
            final f = await FilePicker.pickFile();
            if (f == null) return;
            final size = await f.xFile.length();
            if (mounted) {
              setState(() {
                _file = f;
                _fileSize = size;
              });
            }
          },
        )
      else
        TextFormField(
          controller: _url,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'Link'),
          validator: (v) => requiredText(v, 'Paste the link.'),
        ),
      FieldLabel(
        'Category',
        child: ChoiceChips<VaultCategory>(
          values: VaultCategory.values,
          selected: _category,
          label: (c) => c.label,
          icon: AppIcons.vault,
          onSelected: (v) => setState(() => _category = v),
        ),
      ),
      TextFormField(
        controller: _desc,
        decoration: const InputDecoration(labelText: 'Description (optional)'),
      ),
    ],
  );
}
