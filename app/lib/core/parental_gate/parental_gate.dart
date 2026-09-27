import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'gate_logic.dart';

/// Grown-up check in front of settings, purchases, links, permissions and the
/// parent dashboard (CLAUDE.md hard rule 3).
class ParentalGate extends StatefulWidget {
  const ParentalGate({super.key, this.random});

  final Random? random;

  /// Shows the gate full-screen. Resolves to true only when the right number
  /// was typed; back, cancel or any other way out resolves to false.
  static Future<bool> request(BuildContext context, {Random? random}) async {
    final passed = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => ParentalGate(random: random)));
    return passed ?? false;
  }

  /// Opens [builder]'s page only after the gate is passed.
  static Future<void> open(BuildContext context, WidgetBuilder builder, {Random? random}) async {
    final navigator = Navigator.of(context);
    if (await request(context, random: random)) {
      await navigator.push(MaterialPageRoute<void>(builder: builder));
    }
  }

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  late final GateChallenge _challenge = GateChallenge(random: widget.random);
  bool _failed = false;

  void _tap(int digit) {
    final result = _challenge.enter(digit);
    if (result == GateResult.passed) {
      Navigator.of(context).pop(true);
      return;
    }
    // "Try again" shows after a wrong number until the next digit is typed.
    setState(() => _failed = result == GateResult.failed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.gateTitle),
        leading: IconButton(
          key: const Key('gate.cancel'),
          tooltip: l.gateCancel,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.gateInstruction, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    _challenge.words(locale),
                    key: const Key('gate.words'),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _Slots(filled: _challenge.input.length),
                  SizedBox(
                    height: 32,
                    child: _failed ? Text(l.gateTryAgain, style: TextStyle(color: theme.colorScheme.error)) : null,
                  ),
                  _Keypad(onDigit: _tap, onDelete: () => setState(_challenge.deleteLast), deleteLabel: l.gateDelete),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slots extends StatelessWidget {
  const _Slots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < GateChallenge.digits; i++)
          Container(
            margin: const EdgeInsets.all(6),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? color : null,
              border: Border.all(color: color, width: 2),
            ),
          ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onDelete, required this.deleteLabel});

  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    Widget key(int d) => Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 72,
        height: 64,
        child: FilledButton.tonal(
          key: Key('gate.digit.$d'),
          onPressed: () => onDigit(d),
          child: Text('$d', style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) key(d)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 84),
            key(0),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 72,
                height: 64,
                child: IconButton(
                  key: const Key('gate.delete'),
                  tooltip: deleteLabel,
                  onPressed: onDelete,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
