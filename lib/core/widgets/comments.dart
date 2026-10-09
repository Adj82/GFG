import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/derived.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../utils/format.dart';
import 'basics.dart';

/// Comment thread for a task, event or expense (doc §5: "task- and
/// event-scoped comment threads" ship before full domain chat).
class CommentsThread extends ConsumerStatefulWidget {
  const CommentsThread({
    super.key,
    required this.parent,
    required this.parentId,
    required this.subject,
    required this.route,
    required this.notifyIds,
  });

  final CommentParent parent;
  final String parentId;
  final String subject;
  final String route;

  /// People who should be pinged about new comments.
  final Iterable<String> notifyIds;

  @override
  ConsumerState<CommentsThread> createState() => _CommentsThreadState();
}

class _CommentsThreadState extends ConsumerState<CommentsThread> {
  final _controller = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    await ref
        .read(commentActionsProvider)
        .add(
          parent: widget.parent,
          parentId: widget.parentId,
          text: text,
          notifyIds: widget.notifyIds,
          route: widget.route,
          subject: widget.subject,
        );
    _controller.clear();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final me = ref.watch(authUserIdProvider);
    final members = ref.watch(memberMapProvider);
    final comments =
        ref
            .watch(commentsProvider)
            .where(
              (c) => c.parent == widget.parent && c.parentId == widget.parentId,
            )
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.md),
            child: Text(
              'No comments yet. Start the conversation.',
              style: context.text.bodyMedium?.copyWith(color: p.inkMuted),
            ),
          )
        else
          for (final c in comments)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(memberName(members, c.authorId), size: 32),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                memberName(members, c.authorId),
                                style: context.text.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Fmt.ago(c.createdAt),
                              style: context.text.bodySmall,
                            ),
                            const Spacer(),
                            if (c.authorId == me)
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () =>
                                    ref.read(commentActionsProvider).delete(c),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: p.inkFaint,
                                    semanticLabel: 'Delete comment',
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(c.text, style: context.text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: Gap.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Add a comment'),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: Gap.sm),
            IconButton.filled(
              onPressed: _busy ? null : _send,
              tooltip: 'Post comment',
              style: IconButton.styleFrom(
                backgroundColor: p.green,
                foregroundColor: p.onGreen,
                minimumSize: const Size(52, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
