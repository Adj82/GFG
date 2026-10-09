import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../data/providers.dart';
import '../../domain/snake_engine.dart';

const _bestKey = 'snake.best';

// The board is drawn in these colours in light and dark, so the game always
// looks like the sign-in banner: a dark contribution graph with lit squares.
const _food = Color(0xFF3FA85A);
const _bodyNear = Color(0xFFE6F4EA);
const _bodyFar = Color(0xFF8FCBA0);
const _head = Color(0xFFFFFFFF);

/// Snake where the food is a word spelled out in contribution squares.
class SnakeGame extends ConsumerStatefulWidget {
  const SnakeGame({super.key});

  @override
  ConsumerState<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends ConsumerState<SnakeGame>
    with WidgetsBindingObserver {
  late final SnakeEngine _e;
  final _focus = FocusNode(debugLabel: 'snake');
  Timer? _timer;
  Offset _swipe = Offset.zero;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(localStoreProvider).setting(_bestKey);
    _e = SnakeEngine(best: int.tryParse(saved ?? '') ?? 0);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tabs stay alive when you switch away; don't let the snake keep moving.
    if (!TickerMode.valuesOf(context).enabled) _pauseSoon();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _pauseSoon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _pauseSoon() {
    _timer?.cancel();
    if (!_e.isRunning) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(_e.pause);
    });
  }

  void _schedule() {
    _timer?.cancel();
    if (!_e.isRunning) return;
    _timer = Timer(Duration(milliseconds: _e.tickMs), _tick);
  }

  void _tick() {
    if (!mounted) return;
    final before = _e.score;
    setState(_e.step);
    if (_e.score > before) HapticFeedback.selectionClick();
    if (_e.status == SnakeStatus.over) HapticFeedback.heavyImpact();
    if (_e.status == SnakeStatus.over || _e.status == SnakeStatus.cleared) {
      _saveBest();
    }
    _schedule();
  }

  void _saveBest() {
    final store = ref.read(localStoreProvider);
    final saved = int.tryParse(store.setting(_bestKey) ?? '') ?? 0;
    if (_e.best > saved) store.setSetting(_bestKey, '${_e.best}');
  }

  void _start() {
    setState(_e.start);
    _focus.requestFocus();
    _schedule();
  }

  void _togglePause() {
    if (_e.isRunning) {
      _timer?.cancel();
      setState(_e.pause);
    } else if (_e.status == SnakeStatus.paused ||
        _e.status == SnakeStatus.ready) {
      _start();
    }
  }

  void _turn(Dir d) {
    if (_e.status == SnakeStatus.over || _e.status == SnakeStatus.cleared) {
      return;
    }
    if (!_e.isRunning) _start();
    _e.turn(d);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final k = event.logicalKey;
    final d = switch (k) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Dir.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Dir.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Dir.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => Dir.right,
      _ => null,
    };
    if (d != null) {
      _turn(d);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.keyP) {
      if (_e.status == SnakeStatus.over || _e.status == SnakeStatus.cleared) {
        _start();
      } else {
        _togglePause();
      }
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter &&
        (_e.status == SnakeStatus.over || _e.status == SnakeStatus.cleared)) {
      _start();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onPan(DragUpdateDetails d) {
    _swipe += d.delta;
    if (_swipe.distance < 14) return;
    final horizontal = _swipe.dx.abs() > _swipe.dy.abs();
    _turn(
      horizontal
          ? (_swipe.dx > 0 ? Dir.right : Dir.left)
          : (_swipe.dy > 0 ? Dir.down : Dir.up),
    );
    _swipe = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final e = _e;
    final ink = p.onForest;

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => _swipe = Offset.zero,
        onPanUpdate: _onPan,
        onTap: _focus.requestFocus,
        child: Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: p.forest,
            borderRadius: BorderRadius.circular(Radii.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Stat('Score', '${e.score}', ink),
                  const SizedBox(width: Gap.xl),
                  _Stat('Best', '${e.best}', ink),
                  const Spacer(),
                  _Stat(
                    'Level ${e.level} · ${e.word}',
                    '${e.eaten}/${e.foodAtStart}',
                    ink,
                    end: true,
                  ),
                  const SizedBox(width: Gap.sm),
                  IconButton(
                    tooltip: e.isRunning ? 'Pause' : 'Play',
                    onPressed:
                        e.status == SnakeStatus.over ||
                            e.status == SnakeStatus.cleared
                        ? null
                        : _togglePause,
                    icon: Icon(
                      e.isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AspectRatio(
                  aspectRatio: _BoardPainter.aspect,
                  child: Semantics(
                    label:
                        'Snake game. Score ${e.score}. ${e.eaten} of ${e.foodAtStart} squares eaten.',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ExcludeSemantics(
                          child: CustomPaint(
                            painter: _BoardPainter(
                              snake: e.snake,
                              food: e.food,
                              empty: ink.withValues(alpha: 0.07),
                              foodColor: _food,
                            ),
                          ),
                        ),
                        if (!e.isRunning) _Overlay(engine: e, onStart: _start),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Gap.lg),
              _DPad(onTurn: _turn, ink: ink),
              const SizedBox(height: Gap.lg),
              Text(
                'Use the arrows, swipe, or press the arrow keys. Eat every lit square to clear the word. The edges wrap around.',
                style: context.text.bodySmall?.copyWith(
                  color: ink.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.ink, {this.end = false});

  final String label;
  final String value;
  final Color ink;
  final bool end;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.text.bodySmall?.copyWith(
          color: ink.withValues(alpha: 0.6),
        ),
      ),
      Text(value, style: context.text.titleLarge?.copyWith(color: ink)),
    ],
  );
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.engine, required this.onStart});

  final SnakeEngine engine;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final e = engine;
    final (title, body, action) = switch (e.status) {
      SnakeStatus.over => (
        'Game over',
        'You scored ${e.score}. Best is ${e.best}.',
        'Play again',
      ),
      SnakeStatus.cleared => (
        '${e.word} cleared!',
        'Next word: ${e.nextWord}. It gets quicker.',
        'Next word',
      ),
      SnakeStatus.paused => ('Paused', 'Take your time.', 'Resume'),
      _ => ('Ready?', 'Eat the lit squares. Swipe to start.', 'Play'),
    };
    return Container(
      decoration: BoxDecoration(
        color: p.forest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(Gap.lg),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.text.headlineMedium?.copyWith(color: p.onForest),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: context.text.bodyMedium?.copyWith(
                color: p.onForest.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: Gap.md),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: p.onForest,
                foregroundColor: p.forest,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.snake,
    required this.food,
    required this.empty,
    required this.foodColor,
  });

  /// Squares are `u` wide with a `0.2u` gutter, like the contribution graph.
  static const _gap = 0.2;
  static const aspect =
      (SnakeEngine.cols + _gap * (SnakeEngine.cols - 1)) /
      (SnakeEngine.rows + _gap * (SnakeEngine.rows - 1));

  final List<Cell> snake;
  final Set<Cell> food;
  final Color empty;
  final Color foodColor;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / (SnakeEngine.cols + _gap * (SnakeEngine.cols - 1));
    final step = u * (1 + _gap);
    final r = Radius.circular(u * 0.28);
    final paint = Paint();

    RRect at(Cell c) => RRect.fromRectAndRadius(
      Rect.fromLTWH(c.$1 * step, c.$2 * step, u, u),
      r,
    );

    paint.color = empty;
    for (var y = 0; y < SnakeEngine.rows; y++) {
      for (var x = 0; x < SnakeEngine.cols; x++) {
        canvas.drawRRect(at((x, y)), paint);
      }
    }
    paint.color = foodColor;
    for (final c in food) {
      canvas.drawRRect(at(c), paint);
    }
    for (var i = snake.length - 1; i >= 0; i--) {
      paint.color = i == 0
          ? _head
          : Color.lerp(_bodyNear, _bodyFar, i / snake.length)!;
      canvas.drawRRect(at(snake[i]), paint);
    }
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}

/// On-screen arrows. Reacts on touch-down so quick turns don't feel laggy.
class _DPad extends StatelessWidget {
  const _DPad({required this.onTurn, required this.ink});

  final void Function(Dir) onTurn;
  final Color ink;

  Widget _key(Dir d, IconData icon, String label) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        onTurn(d);
      },
      child: Container(
        width: 68,
        height: 60,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: ink.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Icon(icon, color: ink, size: 32),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _key(Dir.up, Icons.keyboard_arrow_up_rounded, 'Up'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _key(Dir.left, Icons.keyboard_arrow_left_rounded, 'Left'),
            _key(Dir.down, Icons.keyboard_arrow_down_rounded, 'Down'),
            _key(Dir.right, Icons.keyboard_arrow_right_rounded, 'Right'),
          ],
        ),
      ],
    ),
  );
}
