import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../companion/pip_demo_screen.dart';
import '../content/models.dart';
import '../core/voice/voice_service.dart';
import '../l10n/app_localizations.dart';
import '../worlds/world_map_screen.dart' show showDebugMenu;
import 'dashboard.dart';
import 'privacy_screen.dart';

/// Progress, settings, the full version and privacy for grown-ups.
/// Only reachable through the parental gate (CLAUDE.md hard rule 3).
class ParentArea extends ConsumerWidget {
  const ParentArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    );
    final timer = ref.watch(playTimerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.parentTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              heading(l.parentProgress),
              const ProgressDashboard(),
              heading(l.parentSettings),
              Text(l.parentLanguage, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              const LocaleSwitcher(),
              SwitchListTile(
                key: const Key('bilingual'),
                title: Text(l.parentBilingual),
                value: ref.watch(bilingualProvider),
                onChanged: (v) => ref.read(bilingualProvider.notifier).set(v),
              ),
              heading(l.parentAgeBand),
              SegmentedButton<AgeBand>(
                key: const Key('ageBand'),
                segments: [for (final b in AgeBand.values) ButtonSegment(value: b, label: Text(b.json))],
                selected: {ref.watch(ageBandProvider)},
                onSelectionChanged: (s) => ref.read(ageBandProvider.notifier).set(s.single),
              ),
              heading(l.parentDailyLimit),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in const [0, 15, 30, 45, 60])
                    ChoiceChip(
                      key: Key('limit.$m'),
                      label: Text(m == 0 ? l.parentLimitOff : l.parentMinutes(m)),
                      selected: ref.watch(dailyLimitProvider) == m,
                      onSelected: (_) => ref.read(dailyLimitProvider.notifier).set(m),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ListenableBuilder(
                  listenable: timer,
                  builder: (context, _) => Text(l.parentPlayedToday(timer.playedToday.inMinutes)),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                key: const Key('sound'),
                title: Text(l.parentSound),
                value: ref.watch(soundProvider),
                onChanged: (v) => ref.read(soundProvider.notifier).set(v),
              ),
              SwitchListTile(
                key: const Key('music'),
                title: Text(l.parentMusic),
                value: ref.watch(musicProvider),
                onChanged: (v) => ref.read(musicProvider.notifier).set(v),
              ),
              SwitchListTile(
                key: const Key('captions'),
                title: Text(l.parentCaptions),
                value: ref.watch(captionsProvider),
                onChanged: (v) => ref.read(captionsProvider.notifier).set(v),
              ),
              SwitchListTile(
                key: const Key('reducedMotion'),
                title: Text(l.parentReducedMotion),
                value: ref.watch(reducedMotionProvider),
                onChanged: (v) => ref.read(reducedMotionProvider.notifier).set(v),
              ),
              SwitchListTile(
                key: const Key('largeTargets'),
                title: Text(l.parentLargeTargets),
                value: ref.watch(largeTargetsProvider),
                onChanged: (v) => ref.read(largeTargetsProvider.notifier).set(v),
              ),
              const _MicSwitch(),
              heading(l.parentFullVersion),
              const _FullVersion(),
              heading(l.parentPrivacy),
              ListTile(
                key: const Key('privacy'),
                leading: const Icon(Icons.lock_outline_rounded),
                title: Text(l.parentPrivacyShort),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PrivacyScreen())),
              ),
              if (showDebugMenu)
                ListTile(
                  key: const Key('pipDemo'),
                  leading: const Icon(Icons.pets),
                  title: Text(l.parentPipDemo),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PipDemoScreen())),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Turning the mic on is the only place the app asks for microphone permission.
class _MicSwitch extends ConsumerStatefulWidget {
  const _MicSwitch();

  @override
  ConsumerState<_MicSwitch> createState() => _MicSwitchState();
}

class _MicSwitchState extends ConsumerState<_MicSwitch> {
  bool _denied = false;

  Future<void> _toggle(bool on) async {
    if (!on) {
      ref.read(micEnabledProvider.notifier).set(false);
      return;
    }
    final permission = await ref.read(talkBackProvider).requestPermission();
    if (!mounted) return;
    setState(() => _denied = permission != MicPermission.granted);
    ref.read(micEnabledProvider.notifier).set(permission == MicPermission.granted);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final supported = ref.watch(talkBackProvider).supported;
    return SwitchListTile(
      key: const Key('mic'),
      title: Text(l.parentMicrophone),
      subtitle: Text(!supported ? l.parentMicUnavailable : (_denied ? l.parentMicDenied : l.parentMicHelp)),
      value: supported && ref.watch(micEnabledProvider),
      onChanged: supported ? _toggle : null,
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

/// Price shown up front; buying and restoring only here (PLAN 5.2).
class _FullVersion extends ConsumerStatefulWidget {
  const _FullVersion();

  @override
  ConsumerState<_FullVersion> createState() => _FullVersionState();
}

class _FullVersionState extends ConsumerState<_FullVersion> {
  late final Future<(bool, String?)> _store = () async {
    final s = ref.read(purchaseServiceProvider);
    final ok = await s.available();
    return (ok, ok ? await s.price() : null);
  }();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (ref.watch(fullUnlockProvider)) {
      return ListTile(leading: const Icon(Icons.check_circle), title: Text(l.parentUnlocked));
    }
    return FutureBuilder<(bool, String?)>(
      future: _store,
      builder: (context, snap) {
        final (available, price) = snap.data ?? (false, null);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.parentSamplerInfo),
            const SizedBox(height: 8),
            if (!available)
              Text(l.parentStoreUnavailable, key: const Key('store.unavailable'))
            else
              Wrap(
                spacing: 12,
                children: [
                  FilledButton(
                    key: const Key('store.buy'),
                    onPressed: price == null ? null : () => ref.read(purchaseServiceProvider).buy(),
                    child: Text(l.parentBuy(price ?? '…')),
                  ),
                  OutlinedButton(
                    key: const Key('store.restore'),
                    onPressed: () => ref.read(purchaseServiceProvider).restore(),
                    child: Text(l.parentRestore),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
