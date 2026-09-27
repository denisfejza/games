import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../strings.dart';
import 'tokens.dart';

/// Shows the words Pip is saying, when captions are on.
class CaptionBar extends ConsumerWidget {
  const CaptionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(captionsProvider)) return const SizedBox.shrink();
    final audio = ref.watch(audioServiceProvider);
    final l = AppLocalizations.of(context);
    final tokens = AgeBandTheme.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: audio.caption,
      builder: (context, key, _) {
        final text = key == null ? null : lookupString(l, key);
        if (text == null) return const SizedBox.shrink();
        return Container(
          key: const Key('caption'),
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: tokens.ink.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
        );
      },
    );
  }
}
