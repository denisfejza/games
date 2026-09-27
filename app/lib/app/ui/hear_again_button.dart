import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'big_button.dart';
import 'tokens.dart';

/// Replays the last narration. On every child-facing screen.
class HearAgainButton extends ConsumerWidget {
  const HearAgainButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => BigButton(
    key: const Key('hearAgain'),
    icon: Icons.hearing,
    color: AgeBandTheme.of(context).secondary,
    onPressed: () => ref.read(audioServiceProvider).hearAgain(),
  );
}
