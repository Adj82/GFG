import 'dart:collection';
import 'dart:math';

/// Snake on a contribution graph.
///
/// The lit squares spell a word (GFG, KIIT, ...). Eating one grows the snake;
/// eat them all to clear the word and move to the next. The edges wrap, so a
/// swipe that overshoots doesn't end the run, only biting yourself does.
///
/// Pure Dart with no Flutter imports so the rules can be unit-tested.
typedef Cell = (int, int);

enum Dir {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Dir(this.dx, this.dy);
  final int dx;
  final int dy;

  Dir get opposite => switch (this) {
    Dir.up => Dir.down,
    Dir.down => Dir.up,
    Dir.left => Dir.right,
    Dir.right => Dir.left,
  };
}

enum SnakeStatus { ready, running, paused, over, cleared }

/// 5-wide, 6-tall pixel letters. `#` is a lit square.
abstract final class Glyphs {
  static const height = 6;

  static const _font = <String, List<String>>{
    'G': ['.###.', '#...#', '#....', '#.###', '#...#', '.###.'],
    'F': ['#####', '#....', '####.', '#....', '#....', '#....'],
    'K': ['#...#', '#..#.', '#.#..', '##...', '#.#..', '#..#.'],
    'I': ['###', '.#.', '.#.', '.#.', '.#.', '###'],
    'T': ['#####', '..#..', '..#..', '..#..', '..#..', '..#..'],
    'C': ['.####', '#....', '#....', '#....', '#....', '.####'],
    'O': ['.###.', '#...#', '#...#', '#...#', '#...#', '.###.'],
    'D': ['####.', '#...#', '#...#', '#...#', '#...#', '####.'],
    'E': ['#####', '#....', '####.', '#....', '#....', '#####'],
  };

  /// Columns a word needs, letters one square apart.
  static int widthOf(String word) {
    var w = 0;
    for (final ch in word.split('')) {
      w += _font[ch]![0].length + 1;
    }
    return w - 1;
  }

  /// Lit cells for [word], centred horizontally, starting at row [top].
  static Set<Cell> layout(String word, {required int cols, required int top}) {
    var x0 = ((cols - widthOf(word)) / 2).floor();
    final lit = <Cell>{};
    for (final ch in word.split('')) {
      final g = _font[ch]!;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < g[y].length; x++) {
          if (g[y][x] == '#') lit.add((x0 + x, top + y));
        }
      }
      x0 += g[0].length + 1;
    }
    return lit;
  }
}

class SnakeEngine {
  SnakeEngine({this.best = 0}) {
    _loadLevel();
  }

  static const cols = 23;
  static const rows = 17;
  static const words = ['GFG', 'KIIT', 'CODE', 'GEEK'];
  static const foodTop = 5;
  static const _startLength = 3;

  int level = 1;
  int score = 0;
  int best;
  SnakeStatus status = SnakeStatus.ready;

  /// Head first.
  List<Cell> snake = const [];
  Dir dir = Dir.right;
  Set<Cell> food = {};
  int foodAtStart = 0;

  final Queue<Dir> _queue = Queue();

  String get word => words[(level - 1) % words.length];
  String get nextWord => words[level % words.length];

  /// Squares eaten on this word.
  int get eaten => foodAtStart - food.length;

  /// Milliseconds between moves. Gets quicker each level, within reason.
  int get tickMs => max(85, 190 - 20 * (level - 1));

  bool get isRunning => status == SnakeStatus.running;

  void _loadLevel() {
    food = Glyphs.layout(word, cols: cols, top: foodTop);
    foodAtStart = food.length;
    const y = rows - 1;
    snake = [for (var i = 0; i < _startLength; i++) (_startLength + 1 - i, y)];
    dir = Dir.right;
    _queue.clear();
    status = SnakeStatus.ready;
  }

  /// Fresh run from level one.
  void restart() {
    level = 1;
    score = 0;
    _loadLevel();
  }

  void nextLevel() {
    level++;
    _loadLevel();
  }

  void start() {
    if (status == SnakeStatus.over) restart();
    if (status == SnakeStatus.cleared) nextLevel();
    if (status == SnakeStatus.ready || status == SnakeStatus.paused) {
      status = SnakeStatus.running;
    }
  }

  void pause() {
    if (status == SnakeStatus.running) status = SnakeStatus.paused;
  }

  /// Queue a turn. Ignores reversing into yourself and repeats of the
  /// current heading; keeps at most two so fast swipes still land.
  void turn(Dir d) {
    final ref = _queue.isEmpty ? dir : _queue.last;
    if (d == ref || d == ref.opposite) return;
    if (_queue.length >= 2) return;
    _queue.add(d);
  }

  /// Advance one square.
  void step() {
    if (status != SnakeStatus.running) return;
    if (_queue.isNotEmpty) dir = _queue.removeFirst();

    final head = snake.first;
    final next = (
      (head.$1 + dir.dx + cols) % cols,
      (head.$2 + dir.dy + rows) % rows,
    );
    final ate = food.contains(next);

    // The tail square is free this move unless we just ate.
    final blocking = ate ? snake : snake.sublist(0, snake.length - 1);
    if (blocking.contains(next)) {
      status = SnakeStatus.over;
      best = max(best, score);
      return;
    }

    snake = [next, ...ate ? snake : snake.sublist(0, snake.length - 1)];
    if (!ate) return;

    food = {...food}..remove(next);
    score += 10 * level;
    if (food.isEmpty) {
      score += 50 * level;
      best = max(best, score);
      status = SnakeStatus.cleared;
    }
  }
}
