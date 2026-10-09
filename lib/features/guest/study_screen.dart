import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/links.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/basics.dart';
import '../../core/widgets/page.dart';
import 'guest_shell.dart';

Future<void> openKatalog(BuildContext context) async {
  final ok = await launchUrl(
    Links.katalog,
    mode: LaunchMode.externalApplication,
  );
  if (!ok && context.mounted) {
    Toast.show(
      context,
      'Couldn’t open the link. Try kiitkatalog.gfgkiit.in',
      error: true,
    );
  }
}

/// KIIT Katalog gets a whole tab: it's the thing most students open daily.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return AppPage(
      title: 'Study',
      subtitle: 'Made by KIIT students, for KIIT students',
      showBack: false,
      actions: const [MemberLoginButton()],
      slivers: [
        PagePad(
          top: Gap.sm,
          child: ContentWidth(
            child: Container(
              padding: const EdgeInsets.all(Gap.xl),
              decoration: BoxDecoration(
                color: p.forest,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: p.onForest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'KIIT Katalog',
                          style: context.text.labelMedium?.copyWith(
                            color: p.onForest,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.lg),
                  Text(
                    'Stop hunting for PYQs in group chats.',
                    style: context.text.displaySmall?.copyWith(
                      color: p.onForest,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: Gap.md),
                  Text(
                    'Previous year papers, notes and a section-swap finder, all in one place, built by KIIT students.',
                    style: context.text.bodyLarge?.copyWith(
                      color: p.onForest.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: Gap.xl),
                  FilledButton.icon(
                    onPressed: () => openKatalog(context),
                    icon: const Icon(Icons.north_east_rounded, size: 20),
                    label: const Text('Open KIIT Katalog'),
                    style: FilledButton.styleFrom(
                      backgroundColor: p.onForest,
                      foregroundColor: p.forest,
                      minimumSize: const Size(0, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const PagePad(
          top: Gap.lg,
          child: ContentWidth(
            child: Column(
              children: [
                _Feature(
                  icon: Icons.description_rounded,
                  title: 'PYQs and notes',
                  body:
                      'Browse previous year question papers and study notes before the exam, not after.',
                ),
                SizedBox(height: Gap.md),
                _Feature(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Section swap',
                  body:
                      'Want a different section? Find someone who wants yours.',
                ),
                SizedBox(height: Gap.md),
                _Feature(
                  icon: Icons.groups_rounded,
                  title: 'Community powered',
                  body:
                      'Students share what helped them, so the next batch has it easier.',
                ),
              ],
            ),
          ),
        ),
        PagePad(
          top: Gap.lg,
          child: ContentWidth(
            child: Center(
              child: Text(
                'kiitkatalog.gfgkiit.in',
                style: context.text.bodySmall?.copyWith(color: p.inkFaint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Panel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon, size: 44),
        const SizedBox(width: Gap.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleMedium),
              const SizedBox(height: 2),
              Text(body, style: context.text.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}
