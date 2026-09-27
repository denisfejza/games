import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/models.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';

/// Developer settings, reached through the parental gate. The parent
/// dashboard (PLAN 5.1) replaces it.
class DebugMenu extends ConsumerWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.debugMenu)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l.debugLanguage, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const LocaleSwitcher(),
          const SizedBox(height: 24),
          Text(l.debugAgeBand, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<AgeBand>(
            segments: [for (final b in AgeBand.values) ButtonSegment(value: b, label: Text(b.json))],
            selected: {ref.watch(ageBandProvider)},
            onSelectionChanged: (s) => ref.read(ageBandProvider.notifier).set(s.single),
          ),
        ],
      ),
    );
  }
}

class LocaleSwitcher extends ConsumerWidget {
  const LocaleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SegmentedButton<String>(
      key: const Key('localeSwitcher'),
      segments: [
        ButtonSegment(value: 'sq', label: Text(l.languageAlbanian)),
        ButtonSegment(value: 'en', label: Text(l.languageEnglish)),
      ],
      selected: {ref.watch(localeProvider).languageCode},
      onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(Locale(s.single)),
    );
  }
}
