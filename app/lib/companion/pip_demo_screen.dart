import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'pip_controller.dart';
import 'pip_view.dart';

/// Cycles through every Pip mood (PLAN 1.1 acceptance). Developer/tester only.
class PipDemoScreen extends ConsumerWidget {
  const PipDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pip = ref.read(pipControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pip')),
      body: Column(
        children: [
          const Expanded(child: Center(child: PokeablePip(width: 260))),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in PipMood.values)
                OutlinedButton(key: Key('mood.${m.name}'), onPressed: () => pip.debugSet(m), child: Text(m.name)),
              FilledButton(
                key: const Key('talk'),
                onPressed: () => ref.read(audioServiceProvider).say('helloPip', interrupt: true),
                child: const Text('talk'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
