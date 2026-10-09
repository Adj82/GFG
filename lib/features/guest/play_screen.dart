import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/page.dart';
import '../game/snake_view.dart';
import 'guest_shell.dart';

/// Play tab for visitors.
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppPage(
    title: 'Take a break',
    subtitle: 'Snake, the GFG way',
    showBack: false,
    actions: [MemberLoginButton()],
    slivers: [
      PagePad(
        top: Gap.sm,
        child: ContentWidth(child: SnakeGame()),
      ),
    ],
  );
}

/// The same game for signed-in members, opened from More.
class MemberPlayScreen extends StatelessWidget {
  const MemberPlayScreen({super.key});

  @override
  Widget build(BuildContext context) => const AppPage(
    title: 'Take a break',
    subtitle: 'Snake, the GFG way',
    slivers: [
      PagePad(
        top: Gap.sm,
        child: ContentWidth(child: SnakeGame()),
      ),
    ],
  );
}
