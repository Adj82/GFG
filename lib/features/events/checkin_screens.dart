import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/basics.dart';
import '../../data/derived.dart';
import '../../data/providers.dart';
import '../../domain/actions/work_actions.dart';
import '../../domain/checkin_code.dart';

/// Organiser's screen: a QR and 6-digit code that rotate every 30 seconds,
/// plus a live count. Show this on a projector or a phone at the door.
class CheckInHostScreen extends ConsumerStatefulWidget {
  const CheckInHostScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<CheckInHostScreen> createState() => _CheckInHostScreenState();
}

class _CheckInHostScreenState extends ConsumerState<CheckInHostScreen> {
  Timer? _tick;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = ref.watch(accessProvider);
    final event = ref
        .watch(eventsProvider)
        .where((e) => e.id == widget.eventId)
        .firstOrNull;
    if (a == null || event == null) return const SizedBox.shrink();
    if (!a.canManageEvent(event)) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: EmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Only organisers can run check-in',
          ),
        ),
      );
    }
    final members = ref.watch(memberMapProvider);
    final records = ref.watch(eventAttendanceProvider(event.id)).toList()
      ..sort((x, y) => y.at.compareTo(x.at));
    final actions = ref.read(eventActionsProvider);
    final code = CheckInCode.codeAt(event.checkInSecret, event.id, _now);
    final remaining = CheckInCode.remaining(_now);
    final fraction =
        remaining.inMilliseconds / CheckInCode.window.inMilliseconds;
    final open = event.checkInOpen;

    return Scaffold(
      backgroundColor: p.forest,
      appBar: AppBar(
        backgroundColor: p.forest,
        foregroundColor: p.onForest,
        title: Text(
          'Check-in',
          style: context.text.titleLarge?.copyWith(color: p.onForest),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 820;
            final qrSize =
                (wide ? 320.0 : (box.maxWidth - 2 * Gap.page - 2 * Gap.xl))
                    .clamp(180.0, 360.0);

            final codeCard = Container(
              padding: const EdgeInsets.all(Gap.xl),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(Radii.xl),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: context.text.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(event.venue, style: context.text.bodySmall),
                  const SizedBox(height: Gap.lg),
                  if (open)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: CheckInCode.payload(event.id, code),
                          size: qrSize,
                          padding: EdgeInsets.zero,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: p.forest,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: p.forest,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      height: qrSize,
                      width: qrSize,
                      child: const EmptyState(
                        icon: Icons.qr_code_2_rounded,
                        title: 'Check-in is closed',
                        message: 'Open it when people start arriving.',
                        compact: true,
                      ),
                    ),
                  if (open) ...[
                    const SizedBox(height: Gap.lg),
                    Text('Or type this code', style: context.text.bodySmall),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(Radii.md),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        Toast.show(context, 'Code copied');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Text(
                          '${code.substring(0, 3)} ${code.substring(3)}',
                          style: context.text.displayMedium?.copyWith(
                            letterSpacing: 4,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.sm),
                    SizedBox(
                      width: qrSize,
                      child: Row(
                        children: [
                          Expanded(
                            child: ThinProgress(value: fraction, height: 4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(remaining.inMilliseconds / 1000).ceil()}s',
                            style: context.text.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The code changes every 30 seconds, so screenshots stop working.',
                      style: context.text.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            );

            final side = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${records.length}',
                            style: context.text.displayLarge?.copyWith(
                              color: p.onForest,
                            ),
                          ),
                          Text(
                            'checked in${event.rsvpIds.isEmpty ? '' : ' of ${event.rsvpIds.length} RSVPs'}',
                            style: context.text.bodyMedium?.copyWith(
                              color: p.onForest.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => actions.setCheckInOpen(event, !open),
                      style: FilledButton.styleFrom(
                        backgroundColor: open ? p.red : p.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(open ? 'Close check-in' : 'Open check-in'),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                Text(
                  'Just arrived',
                  style: context.text.titleSmall?.copyWith(color: p.onForest),
                ),
                const SizedBox(height: Gap.sm),
                if (records.isEmpty)
                  Text(
                    'Names appear here as people check in.',
                    style: context.text.bodyMedium?.copyWith(
                      color: p.onForest.withValues(alpha: 0.6),
                    ),
                  )
                else
                  for (final r in records.take(wide ? 14 : 5))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Avatar(memberName(members, r.memberId), size: 32),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: Text(
                              memberName(members, r.memberId),
                              style: context.text.titleSmall?.copyWith(
                                color: p.onForest,
                              ),
                            ),
                          ),
                          Text(
                            Fmt.time(r.at),
                            style: context.text.bodySmall?.copyWith(
                              color: p.onForest.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Gap.page),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: Center(child: codeCard)),
                        const SizedBox(width: Gap.xxl),
                        Expanded(flex: 4, child: side),
                      ],
                    )
                  : Column(
                      children: [
                        codeCard,
                        const SizedBox(height: Gap.xl),
                        side,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// Attendee's screen: scan the organiser's QR, or type the 6-digit code.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _code = TextEditingController();
  MobileScannerController? _controller;
  var _busy = false;
  var _done = false;
  String? _error;
  var _manual = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (_busy || _done) return;
    final event = ref
        .read(eventsProvider)
        .where((e) => e.id == widget.eventId)
        .firstOrNull;
    if (event == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ref.read(eventActionsProvider).checkIn(event, code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
      _done = err == null;
    });
    if (_done) {
      HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final parsed = CheckInCode.parse(raw);
      if (parsed == null) {
        setState(
          () => _error = 'That QR code isn’t a SocietyOS check-in code.',
        );
        continue;
      }
      if (parsed.eventId != widget.eventId) {
        setState(() => _error = 'That code is for a different event.');
        continue;
      }
      _verify(parsed.code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final event = ref
        .watch(eventsProvider)
        .where((e) => e.id == widget.eventId)
        .firstOrNull;

    if (_done) {
      return Scaffold(
        backgroundColor: p.forest,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: p.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 64, color: p.onGreen),
                ),
              ),
              const SizedBox(height: Gap.xl),
              Text(
                'You’re checked in',
                style: context.text.headlineLarge?.copyWith(color: p.onForest),
              ),
              const SizedBox(height: 4),
              Text(
                event?.title ?? '',
                style: context.text.bodyLarge?.copyWith(
                  color: p.onForest.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Check in',
          style: context.text.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: _manual ? 'Scan instead' : 'Type code',
            icon: Icon(
              _manual ? Icons.qr_code_scanner_rounded : Icons.keyboard_rounded,
            ),
            onPressed: () => setState(() => _manual = !_manual),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _manual
                  ? _ManualEntry(
                      controller: _code,
                      busy: _busy,
                      onSubmit: () => _verify(_code.text),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: _controller,
                          onDetect: _onDetect,
                          errorBuilder: (context, error) => _CameraProblem(
                            onType: () => setState(() => _manual = true),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(color: p.green, width: 3),
                              borderRadius: BorderRadius.circular(Radii.xl),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Gap.page),
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(Gap.md),
                      margin: const EdgeInsets.only(bottom: Gap.md),
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
                  Text(
                    event == null
                        ? ''
                        : 'Point your camera at the code shown at ${event.venue}.',
                    style: context.text.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  const _ManualEntry({
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(Gap.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Type the 6-digit code',
                style: context.text.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Gap.lg),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 7,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                style: context.text.displaySmall?.copyWith(
                  color: p.ink,
                  letterSpacing: 6,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '000 000',
                ),
                onSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: Gap.lg),
              FilledButton(
                onPressed: busy ? null : onSubmit,
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('Check in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraProblem extends StatelessWidget {
  const _CameraProblem({required this.onType});

  final VoidCallback onType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_rounded,
            color: Colors.white54,
            size: 48,
          ),
          const SizedBox(height: Gap.md),
          Text(
            'Camera isn’t available',
            style: context.text.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Allow camera access, or type the code instead.',
            style: context.text.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: Gap.lg),
          FilledButton(onPressed: onType, child: const Text('Type the code')),
        ],
      ),
    );
  }
}
